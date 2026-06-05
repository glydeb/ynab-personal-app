---
trigger: model_decision
description: Used when storing, modifying, or retrieving data from the YNAB API
---

# YNAB SDK Integration Patterns

This document outlines the standard patterns for integrating the official `ynab` Ruby SDK into our AI-driven financial application, leveraging Ruby on Rails, ActiveAgent, and Solid Queue.

## 1. Authentication and Security
> [!CAUTION]
> The `YNAB_ACCESS_TOKEN` MUST NEVER be hardcoded. All secrets must, without exception, be routed through the Rails `credentials.yml.enc` system.

- Use the secure terminal workflow (`bin/rails credentials:edit -e development`) to inject your Personal Access Token.
- The instantiation of `YNAB::API` should retrieve the token securely: `Rails.application.credentials.ynab_access_token`.

## 2. API Client Encapsulation
Do not instantiate `YNAB::API` directly within controllers or agents.
- Wrap the SDK client in a dedicated service object or a dependency injection framework.
- This ensures that ActiveAgent instances can execute financial mutations without directly managing the client's lifecycle or authentication state.

## 3. Rate Limit Mitigation via Data Mirroring
The YNAB API enforces a strict 200 requests per hour limit. To prevent rate exhaustion:
- **Mirroring:** Mirror the YNAB ledger into the local PostgreSQL database.
- **Asynchronous Sync:** Use Solid Queue background jobs to handle the synchronization.
- **Delta Requests:** Append state tokens (e.g., `last_knowledge_of_server`) to endpoints like `GET /plans/{plan_id}/transactions` to fetch only changed entities.

## 4. ActiveAgent Tool Engineering
- **Common Tools Format:** Define all YNAB API interaction capabilities using the Common Tools Format (JSON Schema).
- **Validation:** Force the LLM to extract and format precise data types (like UUIDs) required by the YNAB SDK before invoking the corresponding Ruby method.
- **Example Mapping:** A natural language request to update a payee is parsed into a structured tool call by the agent, mapped to a Ruby method in `YnabTools`, which then invokes the SDK's `update_payee` endpoint.

## 5. Human-in-the-Loop (HITL) Execution
> [!WARNING]
> High-stakes financial data mutations must never be executed autonomously without user oversight.

- Ensure ActiveAgent workflows are paused to allow human review.
- The agent should stage API payload changes (e.g., categorizations, fund assignments) in the UI and only dispatch the final YNAB SDK requests upon explicit user approval.

## 6. Testing Strategy
- **VCR Cassettes:** Use `vcr` to record and replay HTTP interactions, preventing live API calls during tests (consistent with the `ynab-sdk-ruby` gem's internal testing).
- **FakeLLMProvider:** Configure the `fake_llm` service in test environments to intercept prompts and return deterministic, mocked structured outputs without incurring external API latency.
