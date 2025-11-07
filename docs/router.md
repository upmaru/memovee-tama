# Router Module Documentation

## Overview

The router module is a core component of the Memovee system responsible for intelligently routing user messages to appropriate classification handlers based on message content and semantics.

## Architecture Diagram

```mermaid
flowchart LR
    A[Router Module<br/>module.router] --> B[memovee.space<br/>Root Messaging Space]
    B --> C[User Message<br/>module.memovee.schemas user-message id]

    subgraph Classifications["Target Classifications"]
        D[Off Topic<br/>tama_class.off-topic]
        F[Introductory<br/>tama_class.introductory]
        H[Curse<br/>tama_class.curse]
        J[Greeting<br/>tama_class.greeting]
        L[Media Detail<br/>tama_class.media-detail]
        N[Media Browsing<br/>tama_class.media-browsing]
        P[Person Detail<br/>tama_class.person-detail]
        R[Person Browsing<br/>tama_class.person-browsing]
    end

    subgraph Spaces["Target Spaces"]
        E[basic-conversation<br/>Space]
        M[media-conversation<br/>Space]
    end

    C -->|Routes To| D
    C -->|Routes To| F
    C -->|Routes To| H
    C -->|Routes To| J
    C -->|Routes To| L
    C -->|Routes To| N
    C -->|Routes To| P
    C -->|Routes To| R

    D --> E
    F --> E
    H --> E
    J --> E
    L --> M
    N --> M
    P --> M
    R --> M
```

## Routing Configuration

The router is configured to handle messages from the `user-message` class and route them to the following target classes:

- **Off Topic** - Belongs to `basic-conversation` space
- **Introductory** - Belongs to `basic-conversation` space
- **Curse** - Belongs to `basic-conversation` space
- **Greeting** - Belongs to `basic-conversation` space
- **Media Detail** - Belongs to `media` space
- **Media Browsing** - Belongs to `media` space
- **Person Detail** - Belongs to `media` space
- **Person Browsing** - Belongs to `media` space

## Implementation Details

The router is implemented as a Tama module with the following key components:

- **Module Source**: `upmaru/base/tama//modules/router`
- **Version**: `0.4.8`
- **Root Messaging Space**: `module.memovee.space.id`
- **Network Message Thought**: `module.memovee.network_message_thought_id`
- **Message Routing Class**: `module.global.schemas["message-routing"].id`

Each routing path is defined using `tama_thought_path` resources that connect the router's routing thought to the target classification classes.

## Usage

The router processes incoming user messages and categorizes them into appropriate topics based on the message content. This allows for intelligent handling and processing of different types of conversations within the Memovee system.

The routing mechanism enables the system to:
- Identify conversation topics
- Route messages to specialized handlers
- Maintain organized message flow
- Support multi-domain classification (basic conversation, media, person domains)

## Classes and Spaces Mapping

- `off-topic` → `basic-conversation` space
- `introductory` → `basic-conversation` space
- `curse` → `basic-conversation` space
- `greeting` → `basic-conversation` space
- `media-detail` → `media` space
- `media-browsing` → `media` space
- `person-detail` → `media` space
- `person-browsing` → `media` space

This setup enables the system to efficiently sort and process various types of user messages according to their semantic content while maintaining proper organization across different functional domains.
