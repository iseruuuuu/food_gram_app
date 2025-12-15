# Architecture

## Overview

Food Gram is a modern mobile application built on Flutter + Riverpod + Supabase. The application follows **Clean Architecture** principles combined with **MVVM (Model-View-ViewModel)** pattern, ensuring separation of concerns, testability, and maintainability.

## Technology Stack

### Frontend
- **Flutter**: 3.27.1
- **Dart**: 3.6.0
- **Riverpod**: State management (v2.4.5)
- **GoRouter**: Routing (v12.1.1)

### Backend & Services
- **Supabase**: Authentication, Database, Storage
- **Firebase**: Push notifications (FCM)
- **RevenueCat**: Subscription management
- **Google Mobile Ads**: Ad serving

### Other Key Libraries
- **maplibre_gl**: Map display
- **geolocator**: Location services
- **image_picker**: Image selection
- **cached_network_image**: Image caching

## Architecture Patterns

### Clean Architecture

Food Gram follows Clean Architecture principles with clear separation of layers:

1. **Presentation Layer (UI)**: User interface and user interactions
2. **Domain Layer (Business Logic)**: Business rules and use cases
3. **Data Layer**: Data sources and repositories

The dependency rule ensures that dependencies point inward:
- Outer layers depend on inner layers
- Inner layers are independent of outer layers

### MVVM Pattern

The application implements **MVVM (Model-View-ViewModel)** pattern:

- **Model**: Data models and business entities (`core/model/`)
- **View**: UI components and screens (`ui/screen/`, `ui/component/`)
- **ViewModel**: State management and business logic coordination (`*_view_model.dart`)

### Repository Pattern

The **Repository Pattern** is used to abstract data access:

- **Repository**: Provides a clean API for data operations (`*_repository.dart`)
- **Service**: Contains business logic and data transformation (`*_service.dart`)
- **Data Source**: Actual data sources (Supabase, local storage, etc.)

## Layer Structure

The application is organized into three main layers following Clean Architecture principles:

### 1. Presentation Layer (UI Layer)

**Location**: `lib/ui/`

**Responsibilities**:
- Rendering UI components
- Handling user interactions
- Displaying data from ViewModels
- Managing UI state (loading, error states)
- UI-specific logic (animations, transitions)

**Components**:
- **Screens** (`ui/screen/`): Full-screen views
- **Components** (`ui/component/`): Reusable UI widgets
- **ViewModels** (`*_view_model.dart`): State management for screens

**Dependencies**: 
- ✅ Depends on: Domain Layer (ViewModels, Repositories)
- ❌ Does NOT depend on: Data Layer directly

**What it CAN do**:
- Access ViewModels through Riverpod providers
- Display UI based on ViewModel state
- Trigger user actions through ViewModel methods
- Handle UI-specific logic

**What it CANNOT do**:
- Directly access Supabase or external services
- Contain business logic
- Make direct database queries
- Handle complex data transformations

### 2. Domain Layer (Business Logic Layer)

**Location**: `lib/core/` (business logic parts)

**Responsibilities**:
- Business rules and validation
- Use case orchestration
- Data transformation
- Error handling
- Cache management

**Components**:
- **Services** (`*_service.dart`): Business logic implementation
- **Repositories** (`*_repository.dart`): Data access abstraction
- **Models** (`core/model/`): Domain entities

**Dependencies**:
- ✅ Depends on: Data Layer (Supabase client, storage)
- ❌ Does NOT depend on: Presentation Layer

**What it CAN do**:
- Implement business rules and validation
- Transform data between layers
- Orchestrate multiple data operations
- Manage caching strategies
- Handle errors and exceptions

**What it CANNOT do**:
- Directly render UI
- Access Flutter-specific UI widgets
- Depend on presentation layer

**Key Features**:
- Repository pattern for data abstraction
- Result type (`Result<T, E>`) for error handling
- Cache management integration

### 3. Data Layer

**Location**: `lib/core/supabase/`, `lib/core/api/`

**Responsibilities**:
- Data persistence (Supabase, local storage)
- External API communication
- Data caching
- Data source abstraction

**Components**:
- **Supabase Integration**: Database and storage operations
- **API Clients**: External API communication
- **Cache Managers**: Local caching strategies

**Dependencies**:
- ❌ Does NOT depend on: Presentation or Domain layers
- ✅ Provides: Data access interfaces

**What it CAN do**:
- Perform database operations
- Handle file storage
- Manage API communications
- Implement caching mechanisms

**What it CANNOT do**:
- Contain business logic
- Depend on presentation or domain layers
- Make UI decisions


## State Management (Riverpod)

Riverpod is used throughout the application for state management and dependency injection:

- **Provider**: State definition and dependency injection
- **Repository Provider**: Data access layer abstraction
- **Service Provider**: Business logic layer
- **ViewModel Provider**: UI state management (per screen)

### Provider Hierarchy

```
Global Providers (keepAlive: true)
├── SupabaseClient
├── CurrentUser
└── Configuration

Feature Providers
├── Repository Providers
├── Service Providers
└── ViewModel Providers
```

### Naming Conventions

- `*_provider.dart`: Riverpod provider definitions
- `*_repository.dart`: Data access layer
- `*_service.dart`: Business logic layer
- `*_view_model.dart`: Screen state management

## Dependency Direction

The dependency rule ensures a unidirectional flow:

```
┌─────────────────────────────────────┐
│   Presentation Layer (UI)           │
│   - Screens                          │
│   - Components                       │
│   - ViewModels                        │
└──────────────┬──────────────────────┘
               │ depends on
               ↓
┌─────────────────────────────────────┐
│   Domain Layer (Business Logic)      │
│   - Repositories                     │
│   - Services                         │
│   - Models                           │
└──────────────┬──────────────────────┘
               │ depends on
               ↓
┌─────────────────────────────────────┐
│   Data Layer                        │
│   - Supabase                        │
│   - API Clients                     │
│   - Storage                         │
└─────────────────────────────────────┘
```

### Dependency Rules

1. **Outer → Inner**: Outer layers can depend on inner layers
2. **Inner → Outer**: Inner layers MUST NOT depend on outer layers
3. **Same Layer**: Components in the same layer can depend on each other

## Data Flow

### Standard Data Flow

```
User Action (UI)
    ↓
ViewModel Method
    ↓
Repository Method
    ↓
Service Method
    ↓
Data Source (Supabase/API)
    ↓
Response flows back up
    ↓
ViewModel updates state
    ↓
UI rebuilds with new state
```

### Error Handling Flow

```
Error occurs in Data Layer
    ↓
Service returns Result<T, Exception>
    ↓
Repository propagates Result
    ↓
ViewModel handles Result
    ↓
UI displays error state
```

### Example: Post Creation Flow

```
1. UI Layer (PostScreen)
   └─> Calls: PostViewModel.post()
   
2. ViewModel (PostViewModel)
   └─> Calls: PostRepository.createPost()
   └─> Manages: UI state (loading, success, error)
   
3. Repository (PostRepository)
   └─> Calls: PostService.createPost()
   └─> Handles: Cache invalidation
   
4. Service (PostService)
   └─> Calls: Supabase operations
   └─> Handles: Business logic (image upload, data transformation)
   
5. Data Layer (Supabase)
   └─> Performs: Database insert, file storage
```

## Design Principles

The architecture follows several key design principles to ensure maintainability and scalability:

### Separation of Concerns
- Each layer has a single, well-defined responsibility
- UI logic is separated from business logic
- Business logic is separated from data access
- Clear boundaries between layers

### Dependency Inversion
- High-level modules don't depend on low-level modules
- Both depend on abstractions (interfaces/protocols)
- Implemented through Riverpod providers
- Enables easy testing and mocking

### Single Responsibility Principle
- Each class/component has one reason to change
- ViewModels handle UI state only
- Services handle business logic only
- Repositories handle data access only

### Testability
- Layers can be tested independently
- Dependencies can be mocked via Riverpod
- Business logic is isolated from UI
- Clear interfaces between layers

## Directory Structure

For detailed directory structure, see [DIRECTORY_STRUCTURE.md](./DIRECTORY_STRUCTURE.md).
