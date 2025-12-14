# Production Monitoring Setup Guide

## Overview

This guide sets up comprehensive monitoring for production:
1. **Error Tracking** - Sentry (errors, exceptions, performance)
2. **Uptime Monitoring** - UptimeRobot or similar
3. **Log Aggregation** - Winston with file transport
4. **Health Checks** - Automated endpoint monitoring

---

## 1. Sentry Error Tracking

### Setup Steps

1. **Create Sentry Account**
   - Go to https://sentry.io
   - Create account (free tier available)
   - Create new project: "Los Ricos Tacos Backend"

2. **Get DSN**
   - Copy DSN from project settings
   - Example: `https://abc123@o123456.ingest.sentry.io/123456`

3. **Install Sentry SDK**
   ```bash
   cd backend
   npm install @sentry/node @sentry/profiling-node
   ```

4. **Configure Backend**

   Add to `.env`:
   ```env
   SENTRY_DSN=https://your-dsn@sentry.io/project-id
   SENTRY_ENVIRONMENT=production
   SENTRY_TRACES_SAMPLE_RATE=0.1
   ```

5. **Initialize in server.js**

   Add at the TOP of `backend/server.js` (before other imports):
   ```javascript
   const Sentry = require("@sentry/node");
   const { ProfilingIntegration } = require("@sentry/profiling-node");

   if (process.env.SENTRY_DSN) {
     Sentry.init({
       dsn: process.env.SENTRY_DSN,
       environment: process.env.SENTRY_ENVIRONMENT || 'development',
       integrations: [
         new Sentry.Integrations.Http({ tracing: true }),
         new Sentry.Integrations.Express({ app }),
         new ProfilingIntegration(),
       ],
       tracesSampleRate: parseFloat(process.env.SENTRY_TRACES_SAMPLE_RATE || '0.1'),
       profilesSampleRate: 1.0,
     });
   }
   ```

6. **Add Error Handler**

   In `server.js`, BEFORE other error handlers:
   ```javascript
   // Sentry error handler must be before other error handlers
   app.use(Sentry.Handlers.requestHandler());
   app.use(Sentry.Handlers.tracingHandler());

   // Your routes here...

   // Sentry error handler must be after routes but before other error handlers
   app.use(Sentry.Handlers.errorHandler());
   ```

7. **Test Sentry**
   ```javascript
   // Add test endpoint in development
   app.get('/debug-sentry', (req, res) => {
     throw new Error('Test Sentry error!');
   });
   ```

---

## 2. Uptime Monitoring

### Option A: UptimeRobot (Free)

1. **Create Account**
   - Go to https://uptimerobot.com
   - Sign up (free tier: 50 monitors, 5-min interval)

2. **Add Monitors**

   **Frontend Monitor:**
   - Type: HTTP(s)
   - URL: https://losricostacos.com
   - Interval: 5 minutes
   - Alert Contacts: Your email

   **Backend API Monitor:**
   - Type: HTTP(s)
   - URL: https://losricostacos.com/api/health
   - Interval: 5 minutes
   - Keyword: "success" or "ok"
   - Alert Contacts: Your email

   **Database Monitor:**
   - Type: Port
   - Host: losricostacos.com
   - Port: 5432 (if exposed)
   - Interval: 5 minutes

3. **Configure Alerts**
   - Email notifications
   - SMS (if available)
   - Webhook to Slack/Discord (optional)

### Option B: Pingdom

Similar setup to UptimeRobot but with more features (paid).

### Option C: Self-Hosted Uptime Kuma

1. **Add to docker-compose:**
   ```yaml
   uptime-kuma:
     image: louislam/uptime-kuma:1
     container_name: uptime-kuma
     ports:
       - "3001:3001"
     volumes:
       - uptime-kuma-data:/app/data
     restart: unless-stopped
   ```

2. **Access:** http://localhost:3001
3. **Add Monitors:** Same as UptimeRobot

---

## 3. Log Aggregation with Winston

### Install Winston

```bash
cd backend
npm install winston winston-daily-rotate-file
```

### Configure Logger

Create `backend/utils/logger.js`:
```javascript
const winston = require('winston');
const DailyRotateFile = require('winston-daily-rotate-file');

const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

const transports = [
  // Console output
  new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }),

  // File output with rotation
  new DailyRotateFile({
    filename: 'logs/application-%DATE%.log',
    datePattern: 'YYYY-MM-DD',
    maxSize: '20m',
    maxFiles: '14d',
    level: 'info'
  }),

  // Error logs
  new DailyRotateFile({
    filename: 'logs/error-%DATE%.log',
    datePattern: 'YYYY-MM-DD',
    maxSize: '20m',
    maxFiles: '30d',
    level: 'error'
  })
];

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  transports,
  exitOnError: false
});

module.exports = logger;
```

### Use Logger

Replace `console.log` with:
```javascript
const logger = require('./utils/logger');

// Instead of console.log
logger.info('User logged in', { userId: user.id, email: user.email });

// Instead of console.error
logger.error('Database connection failed', { error: err.message });

// In catch blocks
catch (error) {
  logger.error('Order creation failed', {
    error: error.message,
    stack: error.stack,
    userId: req.user?.id
  });
}
```

### Add to .gitignore

```
logs/
*.log
```

---

## 4. Health Check Monitoring

### Create Comprehensive Health Check

Update `backend/routes/health.js`:
```javascript
const router = require('express').Router();
const pool = require('../config/database');

router.get('/health', async (req, res) => {
  const health = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    checks: {}
  };

  // Database check
  try {
    const result = await pool.query('SELECT NOW()');
    health.checks.database = { status: 'healthy', timestamp: result.rows[0].now };
  } catch (error) {
    health.status = 'degraded';
    health.checks.database = { status: 'unhealthy', error: error.message };
  }

  // Memory check
  const memUsage = process.memoryUsage();
  health.checks.memory = {
    status: memUsage.heapUsed < 500 * 1024 * 1024 ? 'healthy' : 'warning',
    heapUsed: `${Math.round(memUsage.heapUsed / 1024 / 1024)}MB`,
    heapTotal: `${Math.round(memUsage.heapTotal / 1024 / 1024)}MB`
  };

  // Response
  const statusCode = health.status === 'ok' ? 200 : 503;
  res.status(statusCode).json(health);
});

module.exports = router;
```

---

## 5. Alert Thresholds

Configure alerts for:

| Metric | Warning | Critical |
|--------|---------|----------|
| API Response Time | > 1s | > 3s |
| Error Rate | > 1% | > 5% |
| CPU Usage | > 70% | > 90% |
| Memory Usage | > 80% | > 95% |
| Disk Space | < 20% free | < 10% free |
| Database Connections | > 80% pool | > 95% pool |
| Uptime | < 99% | < 95% |

---

## 6. Monitoring Dashboard

### Option A: Grafana + Prometheus

Advanced monitoring with custom dashboards.

### Option B: Simple Status Page

Use Uptime Kuma status page feature for public status display.

---

## 7. Testing Monitoring

### Test Error Tracking

```bash
# Trigger test error
curl http://localhost:5001/debug-sentry

# Check Sentry dashboard for error
```

### Test Uptime Alerts

1. Stop backend: `docker compose stop backend`
2. Wait 5 minutes
3. Verify alert received
4. Restart: `docker compose start backend`

### Test Logging

```bash
# Generate logs
curl http://localhost:5001/api/health

# Check log files
tail -f logs/application-$(date +%Y-%m-%d).log
```

---

## 8. Production Checklist

- [ ] Sentry DSN configured in production .env
- [ ] Uptime monitors created for frontend + backend
- [ ] Alert email/SMS configured
- [ ] Winston logging writing to files
- [ ] Log rotation configured (14 days retention)
- [ ] Health endpoint returns detailed status
- [ ] Test alerts by stopping services
- [ ] Document on-call procedures
- [ ] Set up incident response plan

---

## 9. Environment Variables

Add to `.env`:
```env
# Monitoring
SENTRY_DSN=https://your-dsn@sentry.io/project-id
SENTRY_ENVIRONMENT=production
SENTRY_TRACES_SAMPLE_RATE=0.1
LOG_LEVEL=info

# Alerts
ALERT_EMAIL=your-email@example.com
```

---

## 10. Costs (Estimated)

- **Sentry Free Tier:** 5,000 errors/month
- **UptimeRobot Free:** 50 monitors, 5-min checks
- **Winston:** Free (self-hosted logs)

**Total:** $0/month for small-medium traffic

Upgrade when you exceed free tiers or need advanced features.
