# Memovee Tama

Memovee app tama configuration.

## Getting Started

To get started with the Memovee Tama project, you'll need to set up your environment and deploy the infrastructure using Terraform.

### Prerequisites

- Terraform v1.0.0 or higher
- Access to a Tama instance
- Appropriate API keys for external services (Mistral, X.ai, Elasticsearch)

### Setup Instructions

1. Clone this repository
2. Initialize Terraform:
   ```
   terraform init
   ```
3. Create a `.auto.tfvars` file with your configuration values:
   ```
   tama_base_url = "your-tama-base-url"
   tama_api_key = "your-tama-api-key"
   mistral_api_key = "your-mistral-api-key"
   xai_api_key = "your-xai-api-key"
   elasticsearch_endpoint = "your-elasticsearch-endpoint"
   elasticsearch_management_api_key = "your-elasticsearch-api-key"
   ```
4. Plan and apply the configuration:
   ```
   terraform plan
   terraform apply
   ```

## Project Detail

This project consists of several Terraform files that define different components of the Memovee Tama configuration. Each file serves a specific purpose in setting up the various modules and components.

### `configurations.tf`

This file sets up the Tama provider with the required base URL and API key variables. It establishes the connection to the Tama platform that will be used for managing the various components and modules defined in this configuration.

### `versions.tf`

Defines the Terraform version requirements and the required provider for Tama. This ensures compatibility with the Tama provider version 0.2+ and sets the minimum required Terraform version to 1.0.0.

### `models.tf`

Configures the inference services for the system. It defines two main modules:
- Mistral module with two models: `mistral-medium-latest` and `mistral-small-latest`
- X.ai module with two models: `grok-3-mini` and `grok-3-mini-fast`

These modules handle the integration with external large language models for various AI functionalities.

### `elasticsearch.tf`

Sets up the Elasticsearch module that handles indexing and searching capabilities. This is used for storing and retrieving structured data with full-text search capabilities.

### `main.tf`

This is the core configuration file that sets up the main Memovee components. It includes:
- A global module that provides shared functionality
- A memovee messaging module that serves as the primary interface
- Two prompts for defining the Memovee personality and reply template
- A reply generation chain with associated processors
- Configuration for handling reply generation with specific models and contexts

### `basic.tf`

Handles basic conversation functionality. This file sets up:
- A basic conversation space
- Several classes for handling different conversation flows:
  - `off-topic`: Handles off-topic messages
  - `greeting`: Handles greeting interactions
  - `introductory`: Manages introductory conversations
  - `curse`: Manages curse word detection
- Integration with personalization and prompt assembly spaces
- Chain definitions for profile checking and updating processes
- Associated prompts and tooling for profile operations

### `media.tf`

Manages media-related conversation components. It defines:
- A media conversation space
- Four classes for handling different types of media-related data:
  - `media-detail`: Details about media content
  - `media-browsing`: Browsing media content
  - `person-detail`: Details about people
  - `person-browsing`: Browsing person-related information
- An extract and embed module for processing media conversation data

### `personalization.tf`

Sets up the personalization module for user-specific content. This file:
- Creates a personalization space
- Defines a personalization specification with endpoint `/internal/personalization`
- Sets up data sources for profile actions (`get-profile` and `upsert-profile`)
- Configures the specification with a YAML schema file

### `prompt-assembly.tf`

Handles the prompt assembly functionality. This file:
- Creates a prompt assembly space
- Defines a `context-component` class for assembling contextual information
- Sets up bridges to connect the prompt assembly space with the main memovee space
- Configures chains and modular thoughts for context assembly workflows
- Includes nodes for handling the context assembly process

### `router.tf`

Manages message routing functionality. It:
- Sets up a router module that handles message classification
- Connects to the main memovee space
- Uses a classification prompt from `router/classify.md`
- Routes messages to various classes based on content:
  - Off-topic messages
  - Introductory messages
  - Curse word messages
  - Greeting messages
  - Media detail messages
  - Media browsing messages
  - Person detail messages
  - Person browsing messages
- Defines thought paths for routing messages to appropriate handlers

### `movie-db.tf`

Contains configuration for movie database integrations and related functionality. This file is responsible for connecting with movie database services and handling movie-related data processing.