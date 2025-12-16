# InkWell Monorepo

Unified development environment for InkWell web and mobile applications.

## Structure
- `shared/` - Firebase backend (functions, rules, config)
- `web/` - Web application  
- `mobile/` - React Native mobile app (coming soon)

## Quick Start

### First time setup
```bash
git clone --recurse-submodules https://github.com/PegasusRealm/inkwell-monorepo.git
cd inkwell-monorepo
```

### Pull latest changes
```bash
./scripts/sync-all.sh
```

### Deploy backend
```bash
cd shared
firebase deploy
```

## Development Workflow

See [DEVELOPMENT-WORKFLOW.md](DEVELOPMENT-WORKFLOW.md) for detailed instructions.

## GitHub Repositories

- Main: https://github.com/PegasusRealm/inkwell-monorepo
- Shared: https://github.com/PegasusRealm/inkwell-shared
- Web: https://github.com/PegasusRealm/inkwell-web
- Mobile: https://github.com/PegasusRealm/inkwell-mobile (coming soon)
