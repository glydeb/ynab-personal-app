---
trigger: model_decision
description: When making changes to the application's architecture, dependencies, or environment, you must ensure the `README.md` file is kept up to date.
---

# README Maintenance Rule

## Triggers

This rule applies when you:

- Add, update, or remove system dependencies (e.g., Ruby version, database type).
- Introduce new infrastructure or background services (e.g., changing from Solid Queue to Redis).
- Modify the local development workflow or commands (e.g., changes to `bin/dev`).
- Add external integrations that require new environmental variables or secret configuration.

## Actions

When any of the above triggers occur, you MUST:

1. Update the `README.md` to accurately reflect the changes.
2. Ensure that any new setup steps or configuration requirements are clearly documented in the appropriate sections (e.g., "System Dependencies", "Configuration", or "Running the Application Locally").
