# Memovee Tama

## Summary

This repository contains the Terraform configuration for the Memovee Tama application, which provides a comprehensive AI-powered conversational platform integrating with various services including Tama, Mistral, X.ai, and Elasticsearch. The system supports advanced features like personalized conversations, media handling, and intelligent message routing.

## Table of Contents

- [Overview](#overview)
- [Core Components](#core-components)
- [Architecture](#architecture)
- [Key Modules](#key-modules)
- [Space Relationships](#space-relationships)
- [Documentation](#documentation)
- [Getting Started](#getting-started)

## Overview

The Memovee Tama system is designed to create an intelligent conversational AI platform that can handle:
- Personalized conversations with user profiles
- Media-related interactions
- Message routing and classification
- Contextual awareness and memory
- Integration with external AI services

## Core Components

### Main Module
- Core memovee messaging module serving as the primary interface
- Reply generation chain with associated processors
- Configuration for handling reply generation with specific models and contexts

### Models

OpenAI

| Function | Model | Reasoning effort | Service tier |
| --- | --- | --- | --- |
| Router - Message Routing | gpt-5-nano | `minimal` | `default` |
| Elasticsearch - Index Mapping Generation | gpt-5-mini | `high` | `default` |
| Movie DB - Index Definition Generation | gpt-5-mini | `high` | `default` |
| Movie DB - Generate Description | gpt-5-nano | `low` | `flex` |
| Movie DB - Generate Setting | gpt-5-nano | `low` | `flex` |

Mistral

| Function | Model |
| --- | --- |
| Media Browsing - Tool Call | mistral-medium-latest |
| Media Detail - Tool Call | mistral-medium-latest |
| Person Browsing - Tool Call | mistral-medium-latest |
| Person Detail - Tool Call | mistral-medium-latest |
| Memovee - Reply Generation | mistral-small-latest |

### Data Storage
- Elasticsearch module for indexing and searching capabilities
- Personalization and prompt assembly spaces

## Architecture

The system is built with a modular architecture that allows for flexible extension and maintenance of different conversational functionalities.

## Key Modules

- **Main**: Core memovee functionality and interfaces
- **Basic**: Basic conversation handling with off-topic, greeting, and introductory flows
- **Media**: Media-related conversation components
- **Personalization**: User-specific content management
- **Prompt Assembly**: Contextual information assembly
- **Router**: Message classification and routing
- **Movie Database**: Movie information integration

## Space Relationships

The following diagram shows the correct relationships between Tama spaces in the system, based on the actual `tama_space_bridge` resource definitions:

```mermaid
graph LR
    A[Main Memovee Space]
    B[Basic Conversation Space]
    C[Media Conversation Space]
    D[Personalization Space]
    E[Prompt Assembly Space]
    F[Movie DB Space]
    G[Elasticsearch Space]
    A -- "memovee-basic" --> B
    A -- "memovee-media" --> C
    B -- "basic-conversation-personalization" --> D
    B -- "basic-conversation-prompt-assembly" --> E
    C -- "media-conversation-to-movie-db" --> F
    C -- "media-conversation-to-prompt-assembly" --> E
    E -- "prompt-assembly-memovee" --> A
    F -- "movie-db-elasticsearch" --> G
    style A fill:#bbdefb stroke:#333
    style B fill:#c8e6c9 stroke:#333
    style C fill:#ffe0b2 stroke:#333
    style D fill:#f8b6c0 stroke:#333
    style E fill:#e1bee7 stroke:#333
    style F fill:#d7ccc8 stroke:#333
    style G fill:#fff9c4 stroke:#333
```

## Documentation

For detailed information about the various components of the Memovee Tama system, please refer to the following documentation files:

- [Main Module Documentation](docs/main.md)
- [Movie Database Documentation](docs/movie-db.md)
- [Personalization Documentation](docs/personalization.md)
- [Router Module Documentation](docs/router.md)

## Getting Started

To get started with the Memovee Tama project, you'll need to:
1. Set up your environment with the required Terraform version (v1.0.0+)
2. Configure API keys for external services (Tama, Mistral, X.ai, Elasticsearch)
3. Create a `.auto.tfvars` file with your configuration values
4. Run `terraform init`, `terraform plan`, and `terraform apply`
