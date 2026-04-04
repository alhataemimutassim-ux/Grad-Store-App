
AI Project Rules – Flutter Clean Architecture

This document defines the architecture and rules that AI assistants must follow when generating code for this Flutter project.

All explanations must be in Arabic.
All code must remain in English.

---

PROJECT ARCHITECTURE

The project uses:

Flutter
Clean Architecture
Feature-based structure
Reusable Core Layer

Root Structure:

lib/

core/
features/
main.dart

---

CORE LAYER

The core folder contains global functionality shared across the entire application.

Structure:

lib/core/

constants/
errors/
network/
providers/
services/
theme/
utils/
widgets/

---

CORE FOLDER DETAILS

constants/

Contains global constants such as:

api_constants.dart
app_constants.dart
route_constants.dart

---

errors/

Centralized error handling.

Files may include:

exceptions.dart
failures.dart
error_handler.dart

Errors must be converted into user-friendly messages.

---

network/

Handles all API communication.

Files:

api_client.dart
network_info.dart
interceptors.dart

Rules:

All API requests must pass through api_client.dart

Authorization token must be added automatically to headers.

Example:

Authorization: Bearer token

---

providers/

Global providers used across the application.

Examples:

app_provider.dart
auth_provider.dart
theme_provider.dart

---

services/

Application services.

Examples:

navigation_service.dart
storage_service.dart
auth_service.dart

---

theme/

Application UI theme.

Files may include:

app_theme.dart
colors.dart
text_styles.dart
spacing.dart

Must support modern Material 3 design.

---

utils/

Utility helper functions.

Examples:

validators.dart
formatters.dart
extensions.dart

---

widgets/

Reusable UI components.

Examples:

app_button.dart
app_text_field.dart
loading_indicator.dart
error_widget.dart
app_card.dart

All UI components must be reusable and styled.

---

FEATURE ARCHITECTURE

Each feature must follow Clean Architecture.

Location:

lib/features/{feature_name}

Structure:

presentation/
domain/
data/

---

PRESENTATION LAYER

Contains UI logic.

Structure:

pages/
widgets/
provider/

Responsibilities:

UI
State management
Calling UseCases

---

DOMAIN LAYER

Pure business logic.

Structure:

entities/
repositories/
usecases/

Rules:

No dependency on Flutter framework.

---

DATA LAYER

Handles API and local storage.

Structure:

models/
repositories/
datasources/

Responsibilities:

API calls
Model serialization
Repository implementation

---

STATE MANAGEMENT

Use Provider or Riverpod.

Each feature must have its own provider.

---

TOKEN HANDLING

Token must be stored in secure storage.

Location:

core/services/token_service.dart

All API requests must automatically include:

Authorization: Bearer token

---

UI DESIGN RULES

All UI must be modern and attractive.

Use:

Material 3
Rounded cards
Consistent spacing
Smooth animations

Reusable components must be placed in:

core/widgets/

---

ANIMATIONS

Animations must be reusable.

Place them in:

core/utils/animations.dart

Examples:

fade_animation.dart
scale_animation.dart
page_transition.dart

---

WHEN GENERATING A NEW FEATURE

AI must automatically generate:

Entity
Repository interface
UseCase
Model
Datasource
Repository implementation
Provider
Page
Widgets

---

IMPORTANT RULE

All features must follow the same architecture and must use the shared core layer.

Do not duplicate code that already exists in core.

---

END OF RULES





