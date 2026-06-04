# YNAB AI Assistant

This is an AI-driven personal financial management application built on Rails 8. It leverages the `activeagent` framework and the official YNAB Ruby SDK to act as an intelligent, agent-oriented assistant for your You Need A Budget (YNAB) data. The application can automate budget categorization, manage transactions, and provide dynamic financial insights using LLMs (e.g., OpenAI).

## System Dependencies

- **Ruby**: 3.4.2
- **Database**: PostgreSQL (v9.5+)

## Configuration

This project enforces strict security around sensitive credentials. **Never hardcode secrets** such as your YNAB Personal Access Token or OpenAI API keys into the source code. All secrets are managed securely via Rails Credentials.

To edit or access credentials locally, run:
```bash
EDITOR="vim" bin/rails credentials:edit
```

## Database Creation & Initialization

To create the database, load the schema, and run any seed data, simply execute:

```bash
bin/rails db:prepare
```

*(Note: The application uses Solid Cache, Solid Queue, and Solid Cable, which are all database-backed and configured during this setup).*

## How to Run the Test Suite

This application uses RSpec for testing, along with VCR and WebMock for mocking external HTTP requests to YNAB and OpenAI.

To run the test suite:
```bash
bundle exec rspec
```

## Development Environment (Dev Container)

We recommend using the included Dev Container for local development to ensure consistent dependencies and native code auto-reloading without needing to restart Puma for every change.

1. Open this repository in VS Code (or Cursor).
2. Install the **Dev Containers** extension if prompted.
3. Press `Cmd+Shift+P` and select **Dev Containers: Reopen in Container**.
4. The environment will automatically build and install all gems.

## Running the Application Locally

The application uses Puma as its web server and Solid Queue for background job processing. You can run the application, including its background processes, using the provided development script:

```bash
bin/dev
```

## Deployment Instructions

Deployment is managed via Kamal (kamal-deploy.org). Ensure your server environment has Docker installed and that Kamal is configured with the necessary environment variables for production secrets. Use standard Kamal deploy commands.

## Documentation Workflow

To keep this README up to date, adhere to the agent rule defined in `.agents/rules/readme-maintenance.md`:
*Whenever adding new gems, system dependencies, background services, or modifying the local development workflow, you MUST update this README.md to reflect those changes.*
