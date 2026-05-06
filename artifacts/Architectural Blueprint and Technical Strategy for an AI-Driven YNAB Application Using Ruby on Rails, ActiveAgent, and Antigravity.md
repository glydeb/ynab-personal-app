# **Architectural Blueprint and Technical Strategy for an AI-Driven YNAB Application Using Ruby on Rails, ActiveAgent, and Antigravity**

## **Foundational Architecture and Agent-Oriented Programming**

The traditional Ruby on Rails Model-View-Controller architecture is fundamentally augmented by the introduction of ActiveAgent, which positions artificial intelligence agents as specialized controllers capable of reasoning, complex tool execution, and dynamic natural language generation.1 This architecture must seamlessly integrate the non-deterministic reasoning output of Large Language Models (LLMs) with the strictly deterministic, highly structured requirements of the YNAB financial ledger.

### **ActiveAgent Integration within the Rails 8 Ecosystem**

ActiveAgent operates as the missing abstraction layer for artificial intelligence within the Ruby on Rails framework.1 Instead of relying on disparate scripts, complex middleware glue code, or infrastructure-level wrappers, the application defines its intelligent capabilities using classes that inherit from ActiveAgent::Base or an intermediate, application-specific ApplicationAgent.1 This inheritance hierarchy directly mirrors the standard ApplicationController paradigm utilized throughout Rails applications. This design ensures that cross-cutting concerns, such as authentication verification, logging, and rate-limit monitoring, can be centralized effectively within the base class.  
The Ruby and Rails ecosystem features multiple libraries for interacting with Large Language Models, including tools like RubyLLM and Raix.6 However, ActiveAgent is specifically selected for this architecture because it relies heavily on the "convention over configuration" philosophy native to Rails, providing full integration with standard ERB views, backgrounds jobs, and callbacks.6  
To guarantee absolute financial data privacy and prevent any sensitive information leakage to commercial third parties, the application is strictly configured to utilize a local LLM via Ollama. ActiveAgent seamlessly interfaces with Ollama by utilizing the openai gem and overriding the base\_url configuration to point to the local instance (e.g., http://localhost:11434).  
The ActiveAgent framework supports three distinct invocation strategies, each serving a specific phase of the application lifecycle:

| Invocation Strategy | Implementation Syntax | Architectural Purpose |
| :---- | :---- | :---- |
| Direct Invocation | ApplicationAgent.prompt(message: "Hello").generate\_now | Designed for rapid local prototyping, REPL testing, and basic console interaction.9 |
| Parameterized Invocation | SupportAgent.with(user\_id: 123).help.generate\_now | Used when passing structured context and state data into specialized agent actions.9 |
| Action-Based Invocation | Class definition with def help containing a prompt block | The standard production pattern, encapsulating logic within defined controller-like methods.9 |

With the release of Rails 8, the underlying Ruby infrastructure benefits significantly from advancements such as the ZJIT method-based compiler and Ractors for enhanced parallelism.10 These performance optimizations are particularly relevant when processing large arrays of transaction data or orchestrating multiple concurrent background jobs for asynchronous LLM generations.

### **Integrating the YNAB Ruby SDK and Data Mirroring**

Communication with the YNAB platform will be managed via the official ynab Ruby gem, which acts as a robust, strictly typed client for the REST API.13 This library is automatically generated using the OpenAPI Generator, ensuring that all API endpoints, request bodies, and response schemas are perfectly aligned with the latest YNAB server specifications.14  
To mitigate the strict 200 requests per hour rate limit imposed by the YNAB API, the architecture mandates mirroring the YNAB ledger into a local PostgreSQL database. This synchronization will be managed asynchronously by Solid Queue, the default Active Job database-based backend in Rails 8\. The Solid Queue background jobs will utilize the YNAB API's "delta requests" feature, appending a state token to endpoints like GET /plans/{plan\_id}/transactions to efficiently fetch only the entities that have changed since the last sync, minimizing API payload size and preventing rate exhaustion.15  
The architectural integration of this SDK requires wrapping the YNAB::API instantiation within a dedicated service object or a dependency injection framework. This encapsulation ensures that the ActiveAgent instances can access the API client to perform financial mutations without managing its lifecycle or authentication state directly.

### **Data Flow and Agent Interactions**

The system's data flow begins when a user submits a natural language request. This input is first received by a standard Rails controller, which sanitizes the text and invokes the corresponding ActiveAgent class action.1  
The agent processes the natural language through a predefined prompt template that includes JSON schemas defining the available YNAB tools.16 The underlying local LLM evaluates the prompt and returns a structured tool call rather than plain text. ActiveAgent natively intercepts this tool call, parses the payload, and dynamically routes it to the corresponding Ruby method defined within the agent.16 This Ruby method subsequently utilizes the YNAB Ruby SDK to execute the state change against the financial ledger.17 Finally, the result of the API call is returned to the agent's context window, allowing the LLM to formulate a natural language summary that is rendered seamlessly in the Rails ERB view.1

## **ActiveAgent Tool Engineering and Structured Output**

The efficacy of an artificial intelligence financial application relies entirely on the precision with which the LLM can interpret natural language intent and execute strictly deterministic API calls. ActiveAgent provides advanced mechanisms for tool calling and structured output formatting that perfectly align with the rigorous data validation requirements of the YNAB API.18

### **Universal Tool Calling Architecture**

ActiveAgent extends the capabilities of standard LLMs by allowing developers to register standard Ruby methods as executable tools.16 To ensure maximum portability, the application architecture strictly mandates the use of the Common Tools Format.16 This format utilizes standard JSON Schemas to define the exact parameters that the AI must provide when invoking a tool.16

Ruby

module YnabTools  
  extend ActiveSupport::Concern  
    
  PAYEE\_UPDATE\_TOOL \= {  
    name: "update\_payee\_information",  
    description: "Update the metadata for a specific payee within a budget",  
    parameters: {  
      type: "object",  
      properties: {  
        budget\_id: { type: "string", description: "The UUID of the budget, or 'last-used'" },  
        payee\_id: { type: "string", description: "The UUID of the payee to be updated" },  
        name: { type: "string", description: "The corrected name for the payee" }  
      },  
      required: \["budget\_id", "payee\_id"\]  
    }  
  }  
    
  def update\_payee\_information(budget\_id:, payee\_id:, name: nil)  
    \# Service object invocation bridging to YNAB::PayeesApi  
  end  
end

The underlying YNAB SDK expects precise data types for successful execution. By defining these required properties within the ActiveAgent tool schema, the LLM is programmatically forced to extract, format, and validate these entities from the natural language context before the Ruby method is ever invoked.16 This architectural constraint prevents malformed API requests from reaching the YNAB servers.

### **Structured Output and JSON Validation**

In scenarios where the application requires the artificial intelligence to synthesize complex financial insights rather than directly execute a tool, ActiveAgent's structured output mechanisms become critical.18 ActiveAgent supports the json\_object format to ensure data consistency, which guarantees the output is valid JSON syntax and is natively supported by local Ollama models.19  
When analyzing long arrays of mirrored transaction histories for anomalous spending patterns, the agent must return its analysis in a predictable, machine-readable format. The parsed\_json method extracts the JSON payload from the LLM's raw response, automatically normalizing keys using the normalize\_names: :underscore parameter and converting them to symbols for idiomatic Ruby processing.19

### **Testing Strategy and VCR Cassettes**

Financial applications demand rigorous testing methodologies. The architecture specifies the use of RSpec as the primary testing framework, integrated with vcr cassettes, a dependency already present in the ynab-sdk-ruby gem, to prevent live API calls during automated runs.20  
ActiveAgent is uniquely designed for testability, allowing developers to test AI agents using fixtures and VCR cassettes.18 Additionally, developers can configure a FakeLLMProvider within the config/active\_agent.yml test environment block (service: fake\_llm).6 This configuration intercepts the prompt, tracks the generated messages in memory, and returns deterministic, mocked responses without incurring API costs or network latency during continuous integration runs.6

## **Core Application Capabilities and Financial Workflows**

The application leverages ActiveAgent and the mirrored YNAB data to automate and enhance complex financial workflows, applying strict Human-in-the-Loop (HITL) safeguards before executing mutations.

### **Intelligent Transaction Categorization**

The agent utilizes natural language processing to evaluate merchant names, metadata, and transaction memos to identify spending patterns. Upon determining the correct categories, the agent stages the changes. Once approved, it executes a tool mapped to the YNAB SDK's update\_transaction or update\_transactions methods to apply the categorizations in bulk.14

### **Automated Income Allocation**

To automate the assignment of funds, the agent acts on natural language commands to move money from the user's "Ready to Assign" pool. It programmatically updates the assigned amounts for designated categories by executing API calls via the YNAB SDK (e.g., using PATCH /plans/{plan\_id}/categories/{category\_id}).

### **Time Series Budget Forecasting**

The application integrates the prophet-rb Ruby gem to provide native time series forecasting. The agent queries the local mirrored PostgreSQL database for historical income and expense data, feeds this historical time series into Prophet.forecast, and extrapolates future trends. This synthesized data is then utilized to draft a conventional, forward-looking budget.

### **Plan Modification via Fresh Start Sandboxing**

Because the YNAB API restricts the direct programmatic creation of new plans, the application utilizes a sandboxed approach for budget restructuring. The user initiates a "Fresh Start" within the YNAB web application, which safely creates a new plan containing the existing category structure while archiving the original. The agent then connects to this new plan\_id to execute text-prompted modifications—such as updating target goals or restructuring category groups—providing a safe environment for experimentation.

### **Human-in-the-Loop (HITL) Approval Pattern**

Because the agent orchestrates high-stakes financial data mutations, the architecture implements a strict Human-in-the-Loop (HITL) approval pattern. ActiveAgent supports state-managed interruptions where function tools require human approval. The agent stages all transaction categorizations and money movements in the Rails UI, pausing the workflow until the user explicitly reviews and approves the actions, after which the final YNAB API requests are dispatched.

## **Security Infrastructure and Cryptographic Management**

Personal finance applications require rigorous, uncompromising security models. The application must operate securely in a local, single-user mode while maintaining a codebase that is fundamentally safe to publish to open-source public repositories such as GitHub. Furthermore, the architecture must support a seamless transition to a multi-tenant OAuth model for future marketability.

### **Open-Source Credential Management**

Publishing a Ruby on Rails application to a public repository necessitates the absolute exclusion of sensitive cryptographic keys and Personal Access Tokens. The implementation strictly relies on Rails Encrypted Credentials to securely store the YNAB\_ACCESS\_TOKEN.14  
Modern architectures leverage credentials.yml.enc, which encrypts all secrets using a highly secure master.key.22 It is a critical, non-negotiable best practice that the master.key is never committed to the local working directory's source control.23  
To prevent environment contamination, the architecture implements multi-environment credentials.25 Each execution environment possesses an isolated key hierarchy, ensuring that staging and production values are completely inaccessible from a local development machine.  
Developers utilizing the open-source repository will clone the code and execute the terminal command bin/rails credentials:edit \-e development to input their personal API keys.25 This workflow effectively isolates their private financial access from the open-source codebase while providing a unified configuration interface.25

### **Authentication: Personal Access Tokens versus OAuth 2.0**

For the initial local deployment designed strictly for the developer's personal account, the application will authenticate using a Personal Access Token (PAT) generated from the user's YNAB Developer Settings interface.15  
To achieve marketability and support a SaaS business model, the architecture must evolve to support the OAuth 2.0 authorization code grant type.15 The integration of OAuth 2.0 introduces strict architectural security requirements. Embedded user agents—such as internal WebViews utilized within native application wrappers—must be strictly avoided.28 Instead, the authorization request must be routed through a standard, external web browser. To mitigate Cross-Site Request Forgery (CSRF) attacks during this flow, the application must utilize the state parameter to securely link the client's initial request to the authorization server's response.28  
Furthermore, the application must prominently display a highly specific disclaimer indicating that the software is not officially supported by YNAB and require explicit, recorded acknowledgment of this warning message before any functional interaction with the YNAB API is permitted.29

## **Strategic Development Phasing and Execution Plan**

The execution of this architecture requires a highly systematic, phased approach. Leveraging the Antigravity IDE allows the developer to iteratively build, validate, and secure the application while minimizing technical debt.

### **Phase 1: Local Foundations, Secure Infrastructure, and Mirroring Setup**

The primary objective of the initial phase is establishing a rock-solid local development environment, ensuring that the foundational Rails 8 application is operational, and that all security protocols regarding the YNAB Personal Access Token are strictly enforced.

1. **Repository Initialization and Antigravity Configuration:** The developer initializes a new Ruby on Rails 8 application configured to use RSpec for testing. The .agents/rules/ and .agents/skills/ directories are populated with the custom configurations, and the Antigravity JavaScript Execution Policy is set to "Request review".4  
2. **Dependency Management and Framework Installation:** The activeagent, ynab, prophet-rb, rspec-rails, rubocop, and openai gems are explicitly added to the Gemfile.1 The ActiveAgent installation generator is executed.  
3. **Cryptographic Configuration and Token Management:** The developer manually obtains a Personal Access Token from YNAB.15 The secure terminal workflow (bin/rails credentials:edit \-e development) injects the YNAB\_ACCESS\_TOKEN directly into the encrypted vault.14  
4. **Local Model and Queue Configuration:** The config/active\_agent.yml file is configured to use the openai provider block mapped to the local Ollama base\_url (e.g., http://localhost:11434). Solid Queue is initialized to manage the asynchronous data mirroring.

### **Phase 2: Data Synchronization and Core Agent Implementation**

With the infrastructure secured, development focus shifts to syncing the local database and utilizing Agent-Oriented Programming to build the intelligence core.

1. **Data Mirroring Implementation:** Solid Queue jobs are created to securely fetch the initial YNAB ledger via the Ruby SDK and insert it into the local PostgreSQL database. Subsequent jobs are scheduled utilizing YNAB API delta requests to efficiently fetch and update only modified entities.15  
2. **Agent Generation and Action Definition:** Using the Antigravity IDE, the developer issues commands to generate specific agents (e.g., rails generate active\_agent:agent BudgetAgent analyze). Standard ERB views are created alongside these controllers.  
3. **Tool Engineering and Schema Alignment:** The developer implements the mirrored database queries within the ActiveAgent tool structures.16 Antigravity, guided by the activeagent-tool-scaffold skill, ensures that the JSON parameters defined in the agent prompt strictly match the required tools.16  
4. **Verification and HITL Integration:** The system prompts are refined and tested utilizing RSpec fixtures and VCR cassettes. The developer integrates the Human-in-the-Loop workflows to pause executions in the UI before sensitive API dispatches.

### **Phase 3: Market Readiness and OAuth 2.0 Migration**

The final architectural phase addresses the complex transition from a local, single-user application to a marketable software product capable of secure multi-tenant operation.

1. **OAuth Application Registration and Key Ingestion:** The application is officially registered as a Third-Party OAuth App within the YNAB developer ecosystem.15 The newly generated client\_id and client\_secret are securely injected into the staging.yml.enc and production.yml.enc credentials files.15  
2. **Authentication Flow Overhaul:** The local PAT authentication logic is systematically replaced with a robust OAuth 2.0 authorization code flow routed through an external web browser.15  
3. **Legal Compliance and Interface Governance:** The user interface is updated to prominently include the mandatory YNAB third-party disclaimer text and require explicit user acknowledgment.29  
4. **Production Deployment Strategy:** The finalized codebase is safely pushed to a public GitHub repository, structurally stripped of all .key files.24 The production environment hosting provider is configured with the single RAILS\_MASTER\_KEY environment variable.21

#### **Works cited**

1. ActiveAgent Rails framework for Agent Apps \- GitHub, accessed May 4, 2026, [https://github.com/activeagents/activeagent](https://github.com/activeagents/activeagent)  
2. activeagent | RubyGems.org | your community gem host, accessed May 4, 2026, [https://rubygems.org/gems/activeagent/versions/1.0.1](https://rubygems.org/gems/activeagent/versions/1.0.1)  
3. My First Experience Creating Antigravity Skills | by Shir Meir Lador | Google Cloud \- Medium, accessed May 4, 2026, [https://medium.com/google-cloud/my-first-experience-creating-antigravity-skills-7154031fe115](https://medium.com/google-cloud/my-first-experience-creating-antigravity-skills-7154031fe115)  
4. Getting Started with Google Antigravity \- Codelabs, accessed May 4, 2026, [https://codelabs.developers.google.com/getting-started-google-antigravity](https://codelabs.developers.google.com/getting-started-google-antigravity)  
5. Authoring Google Antigravity Skills \- Codelabs, accessed May 4, 2026, [https://codelabs.developers.google.com/getting-started-with-antigravity-skills](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)  
6. Exploring Active Agent, or can we build AI features the Rails way? \- Evil Martians, accessed May 4, 2026, [https://evilmartians.com/chronicles/exploring-active-agent-or-can-we-build-ai-features-the-rails-way](https://evilmartians.com/chronicles/exploring-active-agent-or-can-we-build-ai-features-the-rails-way)  
7. Active Agent (AI Rails Framework) Demo / Pairing Let's Build Your First Agent in Ruby on Rails\! \- YouTube, accessed May 4, 2026, [https://www.youtube.com/watch?v=SnOCOfcH9rU](https://www.youtube.com/watch?v=SnOCOfcH9rU)  
8. RubyLLM 1.0 : r/rails \- Reddit, accessed May 4, 2026, [https://www.reddit.com/r/rails/comments/1j8lpnt/rubyllm\_10/](https://www.reddit.com/r/rails/comments/1j8lpnt/rubyllm_10/)  
9. Getting Started | Active Agent, accessed May 4, 2026, [https://docs.activeagents.ai/getting\_started](https://docs.activeagents.ai/getting_started)  
10. Rails World 2025 \- Sept 4 & 5 in Amsterdam, accessed May 4, 2026, [https://rubyonrails.org/world/2025](https://rubyonrails.org/world/2025)  
11. Aaron Patterson \- Rails World 2025 Closing Keynote \- YouTube, accessed May 4, 2026, [https://www.youtube.com/watch?v=tiuW0JvPa7k](https://www.youtube.com/watch?v=tiuW0JvPa7k)  
12. How I coded a Rails 8 CFP app in 30m with Antigravity (long version) \- Riccardo's Blog, accessed May 4, 2026, [https://ricc.rocks/en/posts/technology/2026-01-22-rails-8-cfp-app-in-30m/](https://ricc.rocks/en/posts/technology/2026-01-22-rails-8-cfp-app-in-30m/)  
13. ynab-api · GitHub Topics, accessed May 4, 2026, [https://github.com/topics/ynab-api](https://github.com/topics/ynab-api)  
14. ynab/ynab-sdk-ruby: Official Ruby client for the YNAB API \- GitHub, accessed May 4, 2026, [https://github.com/ynab/ynab-sdk-ruby](https://github.com/ynab/ynab-sdk-ruby)  
15. YNAB API, accessed May 4, 2026, [https://api.ynab.com/](https://api.ynab.com/)  
16. Tools | Active Agent, accessed May 4, 2026, [https://docs.activeagents.ai/actions/tools](https://docs.activeagents.ai/actions/tools)  
17. ynab-sdk-ruby/docs/PayeesApi.md at main \- GitHub, accessed May 4, 2026, [https://github.com/ynab/ynab-sdk-ruby/blob/master/docs/PayeesApi.md](https://github.com/ynab/ynab-sdk-ruby/blob/master/docs/PayeesApi.md)  
18. Active Agent, accessed May 4, 2026, [https://docs.activeagents.ai/](https://docs.activeagents.ai/)  
19. Structured Output | Active Agent, accessed May 4, 2026, [https://docs.activeagents.ai/actions/structured\_output](https://docs.activeagents.ai/actions/structured_output)  
20. ynab-sdk-ruby/Gemfile.lock at main \- GitHub, accessed May 4, 2026, [https://github.com/ynab/ynab-sdk-ruby/blob/main/Gemfile.lock](https://github.com/ynab/ynab-sdk-ruby/blob/main/Gemfile.lock)  
21. Secure Your Rails App with Rails Credentials: A Practical Guide \- Vonage, accessed May 4, 2026, [https://developer.vonage.com/en/blog/secure-your-rails-app-with-rails-credentials-a-practical-guide](https://developer.vonage.com/en/blog/secure-your-rails-app-with-rails-credentials-a-practical-guide)  
22. A comprehensive examination of Rails Secrets, Credentials, and Secret Key Base · GitHub, accessed May 4, 2026, [https://gist.github.com/brianjbayer/9c7782232327287005b8065697c1041a](https://gist.github.com/brianjbayer/9c7782232327287005b8065697c1041a)  
23. printercu/secure\_credentials: Rails credentials without security issues. With environments support. \- GitHub, accessed May 4, 2026, [https://github.com/printercu/secure\_credentials](https://github.com/printercu/secure_credentials)  
24. How do I open source my Rails' apps without giving away the app's secret keys and credentials \- Stack Overflow, accessed May 4, 2026, [https://stackoverflow.com/questions/3207575/how-do-i-open-source-my-rails-apps-without-giving-away-the-apps-secret-keys-an](https://stackoverflow.com/questions/3207575/how-do-i-open-source-my-rails-apps-without-giving-away-the-apps-secret-keys-an)  
25. RAILS\_MASTER\_KEY and per-environment init \- Ruby on Rails Discussions, accessed May 4, 2026, [https://discuss.rubyonrails.org/t/rails-master-key-and-per-environment-init/82615](https://discuss.rubyonrails.org/t/rails-master-key-and-per-environment-init/82615)  
26. The YNAB API, accessed May 4, 2026, [https://support.ynab.com/en\_us/the-ynab-api-an-overview-BJMgQ3zAq](https://support.ynab.com/en_us/the-ynab-api-an-overview-BJMgQ3zAq)  
27. Security | YNAB, accessed May 4, 2026, [https://www.ynab.com/security](https://www.ynab.com/security)  
28. OAuth 2.0 Best Practices for Native Apps \- Auth0, accessed May 4, 2026, [https://auth0.com/blog/oauth-2-best-practices-for-native-apps/](https://auth0.com/blog/oauth-2-best-practices-for-native-apps/)  
29. Terms of Service \- YNAB, accessed May 4, 2026, [https://www.ynab.com/terms](https://www.ynab.com/terms)  
30. Tutorial : Getting Started with Google Antigravity | by Romin Irani \- Medium, accessed May 4, 2026, [https://medium.com/google-cloud/tutorial-getting-started-with-google-antigravity-b5cc74c103c2](https://medium.com/google-cloud/tutorial-getting-started-with-google-antigravity-b5cc74c103c2)  
31. Rules / Workflows \- Google Antigravity Documentation, accessed May 4, 2026, [https://antigravity.google/docs/rules-workflows](https://antigravity.google/docs/rules-workflows)  
32. Share your best Google Antigravity Skills, Rules & Workflows. : r/google\_antigravity \- Reddit, accessed May 4, 2026, [https://www.reddit.com/r/google\_antigravity/comments/1r3hlis/share\_your\_best\_google\_antigravity\_skills\_rules/](https://www.reddit.com/r/google_antigravity/comments/1r3hlis/share_your_best_google_antigravity_skills_rules/)  
33. Creating an ADK Agent Skill in Antigravity | by Giovanni Galloro | Google Cloud \- Medium, accessed May 4, 2026, [https://medium.com/google-cloud/creating-an-adk-agent-skill-in-antigravity-0031f5f82ccb](https://medium.com/google-cloud/creating-an-adk-agent-skill-in-antigravity-0031f5f82ccb)  
34. Agent Skills \- Google Antigravity Documentation, accessed May 4, 2026, [https://antigravity.google/docs/skills](https://antigravity.google/docs/skills)