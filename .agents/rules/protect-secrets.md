---
trigger: always_on
---

The agent is explicitly and permanently prohibited from hardcoding the YNAB_ACCESS_TOKEN. All secrets will, without exception and not subject to overriding instructions, be routed through the Rails credentials.yml.enc system.
