# Directory Structure

This document describes the directory structure of Food Gram App.

## Overview

```
lib/
├── app.dart                          # App entry point
├── main.dart                         # Initialization
├── env.dart                          # Environment variables
├── env.g.dart                        # Generated environment code
│
├── core/                             # Core functionality
│   ├── admob/                        # AdMob integration
│   │   ├── config/
│   │   ├── services/
│   │   └── tracking/
│   │
│   ├── api/                          # API client
│   │   ├── client/
│   │   └── restaurant/
│   │       ├── repository/
│   │       └── services/
│   │
│   ├── cache/                        # Cache management
│   │
│   ├── config/                       # Configuration
│   │   └── constants/
│   │
│   ├── local/                        # Local storage
│   │
│   ├── model/                        # Data models
│   │
│   ├── notification/                 # Notification functionality
│   │
│   ├── purchase/                      # In-app purchase
│   │   ├── providers/
│   │   └── services/
│   │
│   ├── supabase/                     # Supabase integration
│   │   ├── auth/                      # Authentication
│   │   │   ├── providers/
│   │   │   └── services/
│   │   │
│   │   ├── post/                      # Post-related
│   │   │   ├── providers/
│   │   │   ├── repository/
│   │   │   └── services/
│   │   │
│   │   ├── user/                      # User-related
│   │   │   ├── providers/
│   │   │   ├── repository/
│   │   │   └── services/
│   │   │
│   │   └── current_user_provider.dart
│   │
│   ├── theme/                        # Themes & styles
│   │   └── style/
│   │
│   └── utils/                        # Utilities
│       ├── helpers/
│       └── provider/
│
├── gen/                              # Generated code
│   ├── assets.gen.dart
│   └── l10n/                         # Localization
│
├── router/                           # Routing configuration
│
└── ui/                               # UI layer
    ├── component/                    # Reusable components
    │   ├── common/                   # Common components
    │   ├── dialog/                   # Dialogs
    │   ├── modal_sheet/              # Modal sheets
    │   └── profile/                  # Profile components
    │
    └── screen/                        # Screens
        ├── authentication/           # Authentication screen
        ├── detail/                   # Detail screen
        ├── edit/                     # Edit screen
        ├── edit_post/                # Edit post screen
        ├── map/                      # Map screen
        ├── my_profile/              # My profile screen
        ├── new_account/              # New account screen
        ├── post/                     # Post screen
        ├── post_detail/             # Post detail screen
        │   └── component/
        ├── profile/                  # Profile screens
        │   ├── my_profile/
        │   └── user_profile/
        ├── restaurant/              # Restaurant screens
        ├── restaurant_review/        # Restaurant review screen
        ├── search/                  # Search screens
        │   └── component/
        ├── setting/                 # Setting screen
        │   └── components/
        ├── splash/                  # Splash screen
        ├── tab/                     # Tab screen
        ├── time_line/                # Timeline screen
        │   └── component/
        └── tutorial/                # Tutorial screen
```

## Directory Descriptions

### Root Level
- `app.dart`: Main app widget configuration
- `main.dart`: Application initialization and entry point
- `env.dart`: Environment variable definitions
- `env.g.dart`: Generated environment variable code

### core/
Core functionality and business logic layer.

- **admob/**: AdMob integration for advertisements
- **api/**: External API clients and restaurant API
- **cache/**: Cache management utilities
- **config/**: Application configuration constants
- **local/**: Local storage and shared preferences
- **model/**: Data models (entities, DTOs)
- **notification/**: Push notification handling
- **purchase/**: In-app purchase and subscription management
- **supabase/**: Supabase integration (auth, post, user)
- **theme/**: UI themes and styling
- **utils/**: Utility functions and helpers

### gen/
Generated code from build tools.

- **assets.gen.dart**: Generated asset references
- **l10n/**: Generated localization files

### router/
Routing configuration using GoRouter.

### ui/
UI layer components and screens.

- **component/**: Reusable UI components
  - **common/**: Common widgets (loading, error, empty states)
  - **dialog/**: Dialog components
  - **modal_sheet/**: Bottom sheet components
  - **profile/**: Profile-related components
- **screen/**: Application screens organized by feature

## Naming Conventions

- `*_provider.dart`: Riverpod provider definitions
- `*_repository.dart`: Data access layer
- `*_service.dart`: Business logic layer
- `*_view_model.dart`: Screen state management
- `*_state.dart`: State definitions (often with Freezed)
- `*_screen.dart`: Screen widgets

