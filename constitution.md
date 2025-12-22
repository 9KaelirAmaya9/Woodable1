# Woodable1 Project Constitution

This is the Woodable1 project constitution. It defines non-negotiable principles and standards for our Docker-based development environment.

## PROJECT OVERVIEW

**Primary Application**: Rico's Tacos - Online ordering and restaurant management system

**Business Context**:
- Operating hours: 9am-9pm CST
- Delivery radius: 5 miles from restaurant
- Minimum order: $15
- Tax rate: 8.25%
- Payment processing: Stripe only

## CORE PRINCIPLES

- **Docker-first**: All services run in containers with health checks
- **Environment variables**: All configuration via .env files
- **Security by default**: Non-root users, JWT auth, no hardcoded secrets
- **Script automation**: Common tasks automated in scripts/
- **Spec-driven development**: Follow the /speckit workflow

## TECHNOLOGY STACK

### Frontend
- React 18+ with TypeScript
- Build with Webpack or Vite
- State management: Context API or Redux
- Testing: Jest + React Testing Library
- Mobile-responsive design (required)
- Spanish language support (i18n)

### Backend
- Node.js 18+ with Express.js
- ES6+ JavaScript
- JWT token authentication
- PostgreSQL client (pg library)
- Stripe integration for payment processing
- Email service for order confirmations
- Testing: Jest + Supertest

### Database
- PostgreSQL 16
- pgAdmin for management
- SQL migrations in postgres/migrations/
- Daily automated backups

### Infrastructure
- Traefik v3 reverse proxy
- Nginx for static assets
- Docker Compose orchestration
- Multi-environment: dev → staging → production

## SECURITY REQUIREMENTS

- JWT authentication on all API endpoints
- All secrets in .env file (never committed to git)
- HTTPS required for production using Traefik Let's Encrypt
- Input validation and sanitization on all user input
- Parameterized queries only (prevent SQL injection)
- bcrypt for password hashing
- Rate limiting on auth and payment endpoints

### Payment Security (PCI Compliance)
- Stripe publishable keys only in frontend
- Stripe secret keys only in backend (never exposed)
- Never store credit card data locally
- Use Stripe Elements for card input
- Validate all payment amounts server-side

## CODE QUALITY STANDARDS

- ESLint for linting JavaScript/TypeScript
- Prettier for code formatting
- Unit tests required for all business logic
- Git pre-commit hooks enforce standards
- Conventional commits for all commit messages
- Minimum 80% test coverage

## DEVELOPMENT WORKFLOW

### Branch Strategy
- `main`: production-ready code only
- `develop`: integration branch
- `feature/*`: new features from spec-kit
- `fix/*`: bug fixes
- `hotfix/*`: emergency production fixes

### Spec-driven Process
1. `/speckit.specify` - Create feature specification
2. `/speckit.plan` - Generate technical implementation plan
3. `/speckit.tasks` - Break plan into implementable tasks
4. `/speckit.implement` - Code the tasks

### Testing Requirements
- Unit tests for business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- All tests must pass before merge

## PERFORMANCE REQUIREMENTS

- Page load time: under 2 seconds
- Menu loads in under 2 seconds
- Checkout process completes in under 30 seconds
- API response time: under 200ms (95th percentile)
- Database queries: under 100ms
- Support 100+ concurrent orders during peak hours
- 99.9% uptime during business hours (9am-9pm CST)
- All data compressed and optimized

## NON-NEGOTIABLES - MUST HAVE

### Infrastructure
✅ Health checks on all Docker services  
✅ Environment variable configuration  
✅ Non-root users in all containers  
✅ Automated backup strategy  
✅ Logging and monitoring  
✅ Error handling and recovery  
✅ Documentation for all features  
✅ Security scanning for containers and code

### Restaurant Features
✅ Menu CRUD operations (admin panel)  
✅ Shopping cart with item customization  
✅ Stripe payment integration  
✅ Order confirmation emails  
✅ Mobile-responsive design  
✅ Spanish language translations  
✅ Delivery radius validation (5 miles)  
✅ Minimum order enforcement ($15)  
✅ Tax calculation (8.25%)  
✅ Business hours enforcement (9am-9pm CST)

## NON-NEGOTIABLES - MUST NOT

❌ Hardcoded credentials anywhere  
❌ Root users in containers  
❌ Production secrets in git  
❌ Unvalidated user input  
❌ Direct database access from frontend  
❌ Unencrypted sensitive data  
❌ Deployment without passing tests  
❌ Store credit card data locally  
❌ Hardcode Stripe API keys  
❌ Skip input validation on forms  
❌ Deploy without testing checkout flow  
❌ Expose Stripe secret keys to frontend

## PROJECT DETAILS

- **Operating hours**: 24/7 availability target
- **Uptime target**: 99.9%
- **Data retention**: 7 years minimum
- **Backup frequency**: Daily
- **Repository**: https://github.com/9KaelirAmaya9/Woodable1
