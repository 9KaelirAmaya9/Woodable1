#!/usr/bin/env python3
"""
Production-Ready Digital Ocean Deployment for Los Ricos Tacos
Integrates with the deployment automation scripts
"""

import os
import sys
import time
import json
import subprocess
from pathlib import Path
from dotenv import load_dotenv
from pydo import Client

# Colors
GREEN = '\033[1;32m'
RED = '\033[1;31m'
YELLOW = '\033[1;33m'
BLUE = '\033[1;36m'
NC = '\033[0m'

def log(msg):
    print(f"{GREEN}[INFO]{NC} {msg}")

def err(msg):
    print(f"{RED}[ERROR]{NC} {msg}", flush=True)

def warn(msg):
    print(f"{YELLOW}[WARN]{NC} {msg}")

# Load environment
env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

# Configuration
DO_API_TOKEN = os.getenv("DO_API_TOKEN")
DO_DROPLET_NAME = os.getenv("DO_DROPLET_NAME", "losricostacos-prod")
DO_API_REGION = os.getenv("DO_API_REGION", "nyc3")
DO_API_SIZE = os.getenv("DO_API_SIZE", "s-2vcpu-4gb")  # Larger for production
DO_API_IMAGE = os.getenv("DO_API_IMAGE", "docker-20-04")  # Docker pre-installed
DO_DOMAIN = os.getenv("WEBSITE_DOMAIN", "losricostacos.com")
SSH_KEY_PATH = Path.home() / ".ssh" / "losricostacos_deploy"
PROJECT_ROOT = Path(__file__).parent.parent

if not DO_API_TOKEN:
    err("DO_API_TOKEN not set in .env")
    sys.exit(1)

client = Client(token=DO_API_TOKEN)

def create_ssh_key():
    """Generate SSH key if it doesn't exist"""
    if SSH_KEY_PATH.exists():
        log(f"SSH key already exists: {SSH_KEY_PATH}")
        return
    
    log(f"Generating SSH key: {SSH_KEY_PATH}")
    SSH_KEY_PATH.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([
        "ssh-keygen", "-t", "ed25519", 
        "-f", str(SSH_KEY_PATH), 
        "-N", "", 
        "-C", "losricostacos-deploy"
    ], check=True)
    log("SSH key generated")

def upload_ssh_key():
    """Upload SSH public key to Digital Ocean"""
    pub_key_path = SSH_KEY_PATH.with_suffix(".pub")
    with open(pub_key_path) as f:
        public_key = f.read().strip()
    
    # Check if key already exists
    keys = client.ssh_keys.list()["ssh_keys"]
    for key in keys:
        if key["public_key"] == public_key:
            log(f"SSH key already uploaded: {key['name']}")
            return key["id"]
    
    # Upload new key
    log("Uploading SSH key to Digital Ocean...")
    result = client.ssh_keys.create({
        "name": "losricostacos-deploy",
        "public_key": public_key
    })
    key_id = result["ssh_key"]["id"]
    log(f"SSH key uploaded with ID: {key_id}")
    return key_id

def create_droplet(ssh_key_id):
    """Create Digital Ocean droplet with cloud-init"""
    
    # Generate cloud-init script
    cloud_init = f"""#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create app directory
mkdir -p /opt/losricostacos
cd /opt/losricostacos

# Clone repository (will be done via SSH after droplet is ready)
echo "Droplet ready for deployment" > /root/READY

# Set up firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "Cloud-init complete at $(date)" >> /var/log/cloud-init-output.log
"""
    
    log("Creating droplet...")
    droplet_spec = {
        "name": DO_DROPLET_NAME,
        "region": DO_API_REGION,
        "size": DO_API_SIZE,
        "image": DO_API_IMAGE,
        "ssh_keys": [ssh_key_id],
        "user_data": cloud_init,
        "tags": ["losricostacos", "production"],
        "ipv6": True,
    }
    
    result = client.droplets.create(droplet_spec)
    droplet_id = result["droplet"]["id"]
    log(f"Droplet created with ID: {droplet_id}")
    
    # Wait for droplet to become active
    log("Waiting for droplet to become active...")
    while True:
        droplet = client.droplets.get(droplet_id)["droplet"]
        if droplet["status"] == "active":
            break
        time.sleep(5)
        print(".", end="", flush=True)
    print()
    
    ip_address = droplet["networks"]["v4"][0]["ip_address"]
    log(f"Droplet is active! IP: {ip_address}")
    
    return droplet_id, ip_address

def update_dns(ip_address):
    """Update DNS records to point to new droplet"""
    log(f"Updating DNS for {DO_DOMAIN}...")
    
    try:
        records = client.domains.list_records(DO_DOMAIN)["domain_records"]
        
        # Update or create A records
        root_updated = False
        www_updated = False
        
        for record in records:
            if record["type"] == "A":
                if record["name"] == "@":
                    client.domains.update_record(DO_DOMAIN, record["id"], {
                        "type": "A",
                        "name": "@",
                        "data": ip_address
                    })
                    log("Updated root A record")
                    root_updated = True
                elif record["name"] == "www":
                    client.domains.update_record(DO_DOMAIN, record["id"], {
                        "type": "A",
                        "name": "www",
                        "data": ip_address
                    })
                    log("Updated www A record")
                    www_updated = True
        
        # Create missing records
        if not root_updated:
            client.domains.create_record(DO_DOMAIN, {
                "type": "A",
                "name": "@",
                "data": ip_address
            })
            log("Created root A record")
        
        if not www_updated:
            client.domains.create_record(DO_DOMAIN, {
                "type": "A",
                "name": "www",
                "data": ip_address
            })
            log("Created www A record")
        
        log(f"DNS updated successfully for {DO_DOMAIN}")
    except Exception as e:
        warn(f"DNS update failed: {e}")
        warn("You may need to update DNS manually")

def wait_for_ssh(ip_address, max_attempts=30):
    """Wait for SSH to become available"""
    log("Waiting for SSH to become available...")
    
    for attempt in range(max_attempts):
        try:
            result = subprocess.run([
                "ssh",
                "-o", "StrictHostKeyChecking=no",
                "-o", "ConnectTimeout=5",
                "-i", str(SSH_KEY_PATH),
                f"root@{ip_address}",
                "echo 'SSH ready'"
            ], capture_output=True, timeout=10)
            
            if result.returncode == 0:
                log("SSH is ready!")
                return True
        except:
            pass
        
        time.sleep(10)
        print(".", end="", flush=True)
    print()
    
    return False

def deploy_application(ip_address):
    """Deploy the application to the droplet"""
    log("Deploying application...")
    
    # Create deployment script
    deploy_script = f"""#!/bin/bash
set -e

# Clone repository
cd /opt/losricostacos
git clone https://github.com/9KaelirAmaya9/Woodable1.git .
cd base2
git checkout production-deploy

# Copy environment file (will be uploaded separately)
# User must manually configure .env before running deployment

echo "Repository cloned. Configure .env and run ./scripts/deploy-production.sh"
"""
    
    # Upload deployment script
    script_path = PROJECT_ROOT / "temp_deploy.sh"
    with open(script_path, "w") as f:
        f.write(deploy_script)
    
    subprocess.run([
        "scp",
        "-o", "StrictHostKeyChecking=no",
        "-i", str(SSH_KEY_PATH),
        str(script_path),
        f"root@{ip_address}:/root/deploy.sh"
    ], check=True)
    
    script_path.unlink()
    
    # Execute deployment script
    subprocess.run([
        "ssh",
        "-o", "StrictHostKeyChecking=no",
        "-i", str(SSH_KEY_PATH),
        f"root@{ip_address}",
        "bash /root/deploy.sh"
    ], check=True)
    
    log("Application deployed!")

def main():
    print(f"""
{BLUE}╔══════════════════════════════════════════════════╗
║  Los Ricos Tacos - Digital Ocean Deployment     ║
╚══════════════════════════════════════════════════╝{NC}
""")
    
    # Step 1: SSH Key
    log("Step 1: Setting up SSH key...")
    create_ssh_key()
    ssh_key_id = upload_ssh_key()
    
    # Step 2: Create Droplet
    log("Step 2: Creating droplet...")
    droplet_id, ip_address = create_droplet(ssh_key_id)
    
    # Step 3: Update DNS
    log("Step 3: Updating DNS...")
    update_dns(ip_address)
    
    # Step 4: Wait for SSH
    log("Step 4: Waiting for SSH...")
    if not wait_for_ssh(ip_address):
        err("SSH did not become available")
        sys.exit(1)
    
    # Step 5: Deploy Application
    log("Step 5: Deploying application...")
    deploy_application(ip_address)
    
    # Summary
    print(f"""
{GREEN}╔══════════════════════════════════════════════════╗
║           Deployment Complete!                   ║
╚══════════════════════════════════════════════════╝{NC}

{BLUE}Droplet Information:{NC}
  ID:         {droplet_id}
  IP:         {ip_address}
  Domain:     {DO_DOMAIN}
  SSH:        ssh -i {SSH_KEY_PATH} root@{ip_address}

{YELLOW}Next Steps:{NC}
  1. SSH into the droplet
  2. Configure /opt/losricostacos/base2/.env
  3. Run: cd /opt/losricostacos/base2 && ./scripts/deploy-production.sh
  4. Wait for DNS propagation (~5-60 minutes)
  5. Visit https://{DO_DOMAIN}

{YELLOW}Important:{NC}
  - Configure .env with production values
  - Change admin passwords after first login
  - Set up database backups
""")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nDeployment cancelled by user")
        sys.exit(1)
    except Exception as e:
        err(f"Deployment failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
