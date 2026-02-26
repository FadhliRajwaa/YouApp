# YouApp - Fullstack Social Profile & Chat Application

A fullstack application consisting of a **Flutter mobile app** (frontend) and a **NestJS REST API** (backend) with real-time chat capabilities. Users can register, login, manage their profile (including horoscope & zodiac calculation), search for other users, and chat in real-time via WebSocket with RabbitMQ message notification.

> **Coding Test Submission** — YouApp Fullstack Developer Assessment

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Database Schemas](#database-schemas)
- [Running Tests](#running-tests)
- [Design Patterns](#design-patterns--architecture-patterns)
- [Docker Services](#docker-services)
- [Environment Variables](#environment-variables)
- [Dual-API Compatibility](#dual-api-compatibility)
- [Key Implementation Details](#key-implementation-details)

---

## Tech Stack

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| Flutter | 3.x | Cross-platform mobile framework |
| Dart | 3.11+ | Programming language |
| GetX | 4.7.2 | State management, routing, DI |
| Dio | 5.8.0 | HTTP client with interceptors |
| SharedPreferences | 2.5.3 | Local token storage |
| ImagePicker | 1.2.1 | Camera & gallery image selection |
| Intl | 0.20.2 | Date formatting |
| GoogleFonts | 6.2.1 | Typography (Inter) |

### Backend
| Technology | Version | Purpose |
|---|---|---|
| NestJS | 11.x | Node.js framework |
| MongoDB | 7.x | NoSQL database |
| Mongoose | 9.2.2 | MongoDB ODM |
| JWT (Passport) | 11.x | Authentication (access + refresh tokens) |
| Socket.io | 4.8.3 | Real-time WebSocket |
| RabbitMQ (amqplib) | 0.10.9 | Message queue notifications |
| Swagger | 11.x | API documentation |
| Docker | - | Containerization |
| bcrypt | 6.0.0 | Password hashing |
| class-validator | 0.14.3 | DTO validation |
| mongodb-memory-server | 11.x | In-memory MongoDB for local dev |

---

## Architecture

### Frontend Architecture
```
Clean Architecture with GetX Pattern
├── app/              → Bindings (DI), Routes (navigation config)
├── core/             → Constants, Network (API client), Theme
├── data/             → Models, Providers (API calls)
├── modules/          → Feature modules (auth, profile, chat)
│   └── feature/
│       ├── controllers/  → Business logic (GetxController)
│       └── views/        → UI screens (GetView)
└── widgets/          → Shared/common widgets
```

### Backend Architecture
```
NestJS Modular Architecture
├── auth/             → Authentication module
│   ├── auth.controller.ts     → POST /register, /login, /refresh
│   ├── auth.service.ts        → Register (bcrypt), Login ($or query)
│   ├── dto/                   → LoginDto, RegisterDto, RefreshDto
│   ├── guards/                → JwtAuthGuard
│   └── strategies/            → Passport JWT (dual-header support)
├── users/            → Profile & user management module
│   ├── users.controller.ts    → CRUD profile + searchUsers
│   ├── users.service.ts       → Profile logic + user search
│   ├── dto/                   → CreateProfileDto, UpdateProfileDto
│   └── schemas/               → MongoDB User schema
├── chat/             → Chat module
│   ├── chat.controller.ts     → sendMessage, viewMessages, unreadCount
│   ├── chat.service.ts        → Message CRUD + read status
│   ├── gateway/               → WebSocket gateway (Socket.io)
│   ├── rabbitmq/              → RabbitMQ pub/sub notification service
│   ├── dto/                   → SendMessageDto
│   └── schemas/               → MongoDB Message schema
└── common/           → Shared utilities
    ├── decorators/            → @CurrentUser param decorator
    └── utils/                 → Horoscope & Zodiac calculation
```

### System Architecture Diagram
```
┌───────────────────────────────────────────────────────────────────┐
│                       Flutter Mobile App                          │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────┐               │
│  │   Auth   │  │   Profile    │  │     Chat     │               │
│  │  Module  │  │    Module    │  │    Module     │               │
│  └────┬─────┘  └──────┬───────┘  └──────┬───────┘               │
│       │               │                 │                        │
│       └───────────────┼─────────────────┘                        │
│                       │ Dio HTTP Client                           │
│                       │ (x-access-token + Authorization: Bearer)  │
└───────────────────────┼──────────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────────────┐
│                     NestJS Backend API                             │
│  ┌─────────────┐  ┌────────────────┐  ┌─────────────────────┐   │
│  │ Auth Module  │  │ Users Module   │  │    Chat Module      │   │
│  │ /api/login   │  │ /api/getProfile│  │ /api/sendMessage    │   │
│  │ /api/register│  │ /api/search..  │  │ /api/viewMessages   │   │
│  │ /api/refresh │  │ CRUD           │  │ WebSocket Gateway   │   │
│  └──────┬──────┘  └───────┬────────┘  └──────┬──────────────┘   │
│         │                 │                   │                   │
│   ┌─────▼─────────────────▼─────┐      ┌─────▼──────────┐      │
│   │      MongoDB (Mongoose)     │      │   RabbitMQ      │      │
│   │  ┌────────┐  ┌───────────┐  │      │  Notification   │      │
│   │  │ Users  │  │ Messages  │  │      │    Queue        │      │
│   │  └────────┘  └───────────┘  │      └────────────────┘      │
│   └─────────────────────────────┘                                │
└───────────────────────────────────────────────────────────────────┘
```

---

## Features

### Authentication
- User registration with email, username, and password
- Login with email or username (JWT token-based)
- **Dual token system**: access token (15m) + refresh token (7d)
- Login uses `$or` query matching (email or username) on backend
- Password hashing with bcrypt (10 salt rounds)
- Auto-redirect to login on token expiration (401 interceptor)
- Persistent session via SharedPreferences
- JWT payload extraction for userId (supports both `sub` and `id` claims)

### Profile Management
- Create, read, and update user profile
- Profile fields: display name, gender, birthday, height, weight, interests
- Automatic **horoscope** calculation based on birthday (Western zodiac signs)
- Automatic **Chinese zodiac** calculation based on birth year
- Profile image selection (camera or gallery)
- Interest tags with add/remove functionality
- Real-time UI updates on save (reactive state with GetX)

### User Search
- Search users by username with real-time debounced search (400ms)
- Partial matching with case-insensitive regex
- Current user excluded from search results
- Returns only public fields: `_id`, `username`, `name`, `profileImage`
- Limit 20 results per query

### Chat System
- REST API for sending and viewing messages
- **User search dialog** — find users by username instead of needing ObjectIDs
- Real-time messaging via **Socket.io** WebSocket gateway
- **RabbitMQ** message notification queue
  - Publisher: sends notification when a message is created
  - Consumer: receives notifications and forwards via WebSocket
- Message read status tracking (`isRead` flag)
- Unread message count endpoint
- Compound index on `(senderId, receiverId, createdAt)` for query performance
- Message population with sender/receiver user details

### Horoscope & Zodiac Calculation

**Western Horoscope** (based on birth month & day):

| Sign | Date Range |
|---|---|
| Aries | Mar 21 - Apr 19 |
| Taurus | Apr 20 - May 20 |
| Gemini | May 21 - Jun 21 |
| Cancer | Jun 22 - Jul 22 |
| Leo | Jul 23 - Aug 22 |
| Virgo | Aug 23 - Sep 22 |
| Libra | Sep 23 - Oct 23 |
| Scorpius | Oct 24 - Nov 21 |
| Sagittarius | Nov 22 - Dec 21 |
| Capricornus | Dec 22 - Jan 19 |
| Aquarius | Jan 20 - Feb 18 |
| Pisces | Feb 19 - Mar 20 |

**Chinese Zodiac** (based on birth year):
Rat, Ox, Tiger, Rabbit, Dragon, Snake, Horse, Goat, Monkey, Rooster, Dog, Pig — calculated as `(year - 1900) % 12`.

---

## Project Structure

```
task-app/
├── frontend/                       # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart               # App entry point
│   │   ├── app/
│   │   │   ├── bindings/           # GetX dependency injection (fenix: true)
│   │   │   │   ├── auth_binding.dart
│   │   │   │   ├── chat_binding.dart
│   │   │   │   └── profile_binding.dart
│   │   │   └── routes/
│   │   │       ├── app_pages.dart      # Route-to-page mapping
│   │   │       └── app_routes.dart     # Route constants
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   └── api_constants.dart  # API URLs & storage keys
│   │   │   ├── network/
│   │   │   │   └── api_client.dart     # Dio HTTP client + dual-header interceptors
│   │   │   └── theme/
│   │   │       ├── app_colors.dart     # Color palette & gradients
│   │   │       └── app_theme.dart      # Material theme config
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart     # User data model + age calc
│   │   │   │   └── message_model.dart  # Chat message model
│   │   │   └── providers/
│   │   │       ├── auth_provider.dart      # Auth API calls
│   │   │       ├── profile_provider.dart   # Profile CRUD API calls
│   │   │       └── chat_provider.dart      # Chat + user search API calls
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   │   ├── controllers/auth_controller.dart   # Login, register, JWT decode
│   │   │   │   └── views/
│   │   │   │       ├── landing_view.dart   # Welcome screen
│   │   │   │       ├── login_view.dart     # Login form
│   │   │   │       └── register_view.dart  # Registration form
│   │   │   ├── profile/
│   │   │   │   ├── controllers/profile_controller.dart  # Profile CRUD, image picker
│   │   │   │   └── views/
│   │   │   │       ├── profile_view.dart       # Profile display + inline edit
│   │   │   │       └── interests_view.dart     # Interest tag editor
│   │   │   └── chat/
│   │   │       ├── controllers/chat_controller.dart  # Chat + user search logic
│   │   │       └── views/
│   │   │           ├── chat_list_view.dart  # Chat list + new chat search dialog
│   │   │           └── chat_room_view.dart  # Chat messages UI
│   │   └── widgets/
│   │       └── common_widgets.dart  # GradientButton, AppTextField, GradientBackground
│   ├── android/
│   │   └── app/src/main/AndroidManifest.xml  # INTERNET permission (release)
│   ├── test/
│   │   ├── unit/                    # Unit tests (2)
│   │   │   ├── api_constants_test.dart
│   │   │   └── user_model_test.dart
│   │   └── widget/                  # Widget tests (31)
│   │       ├── common_widgets_test.dart
│   │       ├── login_view_test.dart
│   │       └── register_view_test.dart
│   ├── integration_test/
│   │   └── app_test.dart            # Integration tests
│   └── pubspec.yaml
│
├── backend/                        # NestJS API server
│   ├── src/
│   │   ├── main.ts                 # Bootstrap (CORS, validation, Swagger)
│   │   ├── app.module.ts           # Root module
│   │   ├── auth/
│   │   │   ├── auth.controller.ts       # POST /register, /login, /refresh
│   │   │   ├── auth.service.ts          # Auth logic ($or login, bcrypt)
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.service.spec.ts     # Unit tests (14 tests)
│   │   │   ├── dto/
│   │   │   │   ├── login.dto.ts         # Dual-format: usernameOrEmail | email+username
│   │   │   │   ├── register.dto.ts      # @IsEmail, @MinLength(6)
│   │   │   │   └── refresh.dto.ts       # Refresh token DTO
│   │   │   ├── guards/
│   │   │   │   └── jwt-auth.guard.ts
│   │   │   └── strategies/
│   │   │       └── jwt.strategy.ts      # Dual-header: x-access-token + Bearer
│   │   ├── users/
│   │   │   ├── users.controller.ts      # CRUD profile + GET /searchUsers
│   │   │   ├── users.service.ts         # Profile logic + user search (regex)
│   │   │   ├── users.module.ts
│   │   │   ├── users.service.spec.ts    # Unit tests (8 tests)
│   │   │   ├── dto/
│   │   │   │   └── profile.dto.ts       # CreateProfileDto, UpdateProfileDto
│   │   │   └── schemas/
│   │   │       └── user.schema.ts       # MongoDB user schema
│   │   ├── chat/
│   │   │   ├── chat.controller.ts       # sendMessage, viewMessages, unreadCount
│   │   │   ├── chat.service.ts          # Message CRUD + read status
│   │   │   ├── chat.module.ts
│   │   │   ├── chat.service.spec.ts     # Unit tests (4 tests)
│   │   │   ├── dto/
│   │   │   │   └── message.dto.ts       # SendMessageDto
│   │   │   ├── gateway/
│   │   │   │   └── chat.gateway.ts      # Socket.io WebSocket gateway
│   │   │   ├── rabbitmq/
│   │   │   │   ├── rabbitmq.service.ts      # RabbitMQ pub/sub service
│   │   │   │   └── rabbitmq.service.spec.ts # Unit tests (15 tests)
│   │   │   └── schemas/
│   │   │       └── message.schema.ts    # MongoDB message schema
│   │   └── common/
│   │       ├── decorators/
│   │       │   └── current-user.decorator.ts  # @CurrentUser param decorator
│   │       └── utils/
│   │           ├── horoscope.util.ts          # Horoscope & Zodiac functions
│   │           └── horoscope.util.spec.ts     # Unit tests (3 tests)
│   ├── test/
│   │   ├── app.e2e-spec.ts         # E2E test
│   │   └── jest-e2e.json
│   ├── start-local.js              # Local dev bootstrap (in-memory MongoDB)
│   ├── docker-compose.yml          # Docker services config
│   ├── Dockerfile                  # Node.js production image
│   ├── .env                        # Environment variables
│   ├── package.json
│   └── tsconfig.json
│
└── README.md                       # This file
```

---

## Getting Started

### Prerequisites
- **Node.js** >= 20.x
- **Flutter** >= 3.x (Dart >= 3.11)
- **Android SDK** (for mobile build)
- **Docker & Docker Compose** *(optional — only for Docker setup)*

### Backend Setup

#### Option 1: Local Development (No Docker Required)

This uses `mongodb-memory-server` to run MongoDB in-memory — no installation needed.

```bash
cd backend

# Install dependencies
npm install

# Start with in-memory MongoDB (auto-builds + starts)
npm run start:local

# API available at http://localhost:3000
# Swagger docs at http://localhost:3000/api-docs
```

> RabbitMQ is optional — if not available, chat still works but without the notification queue. The app logs a warning and continues gracefully.

#### Option 2: Docker (Full Stack)
```bash
cd backend

# Start all services (API + MongoDB + RabbitMQ)
docker-compose up -d

# API available at http://localhost:3000
# Swagger docs at http://localhost:3000/api-docs
# RabbitMQ management UI at http://localhost:15672 (guest/guest)
```

#### Option 3: Manual (External MongoDB)
```bash
cd backend

# Install dependencies
npm install

# Create or edit .env file
# MONGODB_URI=mongodb://localhost:27017/youapp
# JWT_SECRET=youapp-secret-key-2024
# JWT_EXPIRATION=15m
# JWT_REFRESH_SECRET=youapp-refresh-secret-2024
# JWT_REFRESH_EXPIRATION=7d
# RABBITMQ_URI=amqp://guest:guest@localhost:5672
# PORT=3000

# Start in development mode (hot-reload)
npm run start:dev
```

### Frontend Setup

```bash
cd frontend

# Get Flutter dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build release APK
flutter build apk --release

# Install to connected Android device via USB
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

#### API Configuration

The API base URL is configured in `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
  // For local backend (physical device on same WiFi):
  static const String baseUrl = 'http://192.168.x.x:3000';

  // For Android emulator connecting to host machine:
  // static const String baseUrl = 'http://10.0.2.2:3000';

  // For external YouApp test API (no chat support):
  // static const String baseUrl = 'https://techtest.youapp.ai';
}
```

> **Important**: When using a physical Android device, use your computer's local WiFi IP address (e.g., `192.168.x.x`). Find it with `ipconfig` (Windows) or `ifconfig` (Mac/Linux).

---

## API Documentation

Once the backend is running, Swagger documentation is available at:
```
http://localhost:3000/api-docs
```

### Endpoints

#### Authentication

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/api/register` | No | Register a new user |
| `POST` | `/api/login` | No | Login and receive JWT tokens |
| `POST` | `/api/refresh` | No | Refresh access token |

**Register** `POST /api/register`
```json
// Request
{
  "email": "john@example.com",
  "username": "johndoe",
  "password": "password123"
}

// Response 201
{
  "message": "User has been created successfully"
}
```

**Login** `POST /api/login`
```json
// Request — supports both formats:
// Format 1 (our backend):
{ "usernameOrEmail": "john@example.com", "password": "password123" }

// Format 2 (external API compatible):
{ "email": "john@example.com", "username": "johndoe", "password": "password123" }

// Response 200
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "userId": "507f1f77bcf86cd799439011"
}
```

> Login uses `$or` query — matches either email or username field.

**Refresh Token** `POST /api/refresh`
```json
// Request
{ "refresh_token": "eyJhbGciOiJIUzI1NiIs..." }

// Response 200
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

#### Profile

All profile endpoints require authentication header (`x-access-token` or `Authorization: Bearer`).

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/api/createProfile` | JWT | Create user profile |
| `GET` | `/api/getProfile` | JWT | Get current user profile |
| `PUT` | `/api/updateProfile` | JWT | Update user profile |

**Create/Update Profile**
```json
// Request
{
  "name": "John Doe",
  "gender": "Male",
  "birthday": "1995-08-17",
  "height": 175,
  "weight": 70,
  "interests": ["Music", "Sports", "Travel"]
}

// Response — auto-computed horoscope & zodiac
{
  "_id": "507f1f77bcf86cd799439011",
  "email": "john@example.com",
  "username": "johndoe",
  "name": "John Doe",
  "gender": "Male",
  "birthday": "1995-08-17T00:00:00.000Z",
  "height": 175,
  "weight": 70,
  "interests": ["Music", "Sports", "Travel"],
  "horoscope": "Leo",
  "zodiac": "Pig"
}
```

#### User Search

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/searchUsers?query=<username>` | JWT | Search users by username |

**Search Users** `GET /api/searchUsers?query=john`
```json
// Response 200 — current user excluded, max 20 results
[
  {
    "_id": "507f1f77bcf86cd799439011",
    "username": "johndoe",
    "name": "John Doe",
    "profileImage": null
  }
]
```

#### Chat

All chat endpoints require authentication header.

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/api/sendMessage` | JWT | Send a message to another user |
| `GET` | `/api/viewMessages?receiverId=<id>` | JWT | View conversation with a user |
| `GET` | `/api/unreadCount` | JWT | Get unread message count |

**Send Message** `POST /api/sendMessage`
```json
// Request
{
  "receiverId": "507f1f77bcf86cd799439011",
  "content": "Hello, how are you?"
}

// Response 201
{
  "_id": "...",
  "senderId": "...",
  "receiverId": "507f1f77bcf86cd799439011",
  "content": "Hello, how are you?",
  "isRead": false,
  "createdAt": "2026-01-01T00:00:00.000Z"
}
```

**View Messages** `GET /api/viewMessages?receiverId=507f1f77bcf86cd799439011`
```json
// Response 200
{
  "data": [
    {
      "_id": "...",
      "senderId": { "_id": "...", "username": "johndoe", "name": "John" },
      "receiverId": { "_id": "...", "username": "jane", "name": "Jane" },
      "content": "Hello!",
      "isRead": true,
      "createdAt": "2026-01-01T00:00:00.000Z"
    }
  ]
}
```

#### WebSocket Events (Socket.io)

| Event | Direction | Payload | Description |
|---|---|---|---|
| `register` | Client → Server | `{ userId: string }` | Register socket connection |
| `sendMessage` | Client → Server | `{ senderId, receiverId, content }` | Send real-time message |
| `newMessage` | Server → Client | `Message object` | New message notification |
| `notification` | Server → Client | `{ type, message, data }` | RabbitMQ notification |

---

## Database Schemas

### User Collection
```
{
  _id: ObjectId,
  email: String (required, unique),
  username: String (required, unique),
  password: String (required, bcrypt hashed),
  name: String,
  gender: String,
  birthday: Date,
  height: Number,
  weight: Number,
  interests: [String],
  horoscope: String (auto-computed),
  zodiac: String (auto-computed),
  profileImage: String,
  createdAt: Date (auto),
  updatedAt: Date (auto)
}
```

### Message Collection
```
{
  _id: ObjectId,
  senderId: ObjectId (ref: User, indexed),
  receiverId: ObjectId (ref: User, indexed),
  content: String (required),
  isRead: Boolean (default: false),
  createdAt: Date (auto),
  updatedAt: Date (auto)
}

Compound Index: { senderId: 1, receiverId: 1, createdAt: -1 }
```

---

## Running Tests

### Backend Tests
```bash
cd backend

# Run all unit tests
npm test

# Run tests with coverage
npm run test:cov

# Run tests in watch mode
npm run test:watch

# Run e2e tests
npm run test:e2e
```

**Test Results: 44 tests across 5 suites — all passing**
```
PASS  src/auth/auth.service.spec.ts           (14 tests)
PASS  src/users/users.service.spec.ts          (8 tests)
PASS  src/chat/chat.service.spec.ts            (4 tests)
PASS  src/chat/rabbitmq/rabbitmq.service.spec.ts (15 tests)
PASS  src/common/utils/horoscope.util.spec.ts  (3 tests)

Test Suites: 5 passed, 5 total
Tests:       44 passed, 44 total
```

### Frontend Tests
```bash
cd frontend

# Run all tests
flutter test

# Run unit tests only
flutter test test/unit/

# Run widget tests only
flutter test test/widget/

# Run integration tests
flutter test integration_test/
```

**Test Results: 33 tests across 5 files**
```
test/unit/api_constants_test.dart        — API constants validation
test/unit/user_model_test.dart           — User model serialization
test/widget/common_widgets_test.dart     — Shared widget rendering
test/widget/login_view_test.dart         — Login form UI + interactions
test/widget/register_view_test.dart      — Register form UI + interactions
```

---

## Design Patterns & Architecture Patterns

### Frontend
- **Clean Architecture** — Separation of data, domain, and presentation layers
- **Repository Pattern** — Providers abstract API communication from controllers
- **Observer Pattern** — GetX reactive state (`Rx`, `Obx`) for automatic UI updates
- **Dependency Injection** — GetX `Bindings` with `fenix: true` for safe controller recreation after disposal
- **MVC Variant** — Controllers handle logic, Views handle UI, Models represent data
- **Singleton Pattern** — API client shared across providers
- **Debounce Pattern** — User search with 400ms debounce to reduce API calls

### Backend
- **Modular Architecture** — NestJS modules (auth, users, chat) with clear boundaries
- **Dependency Injection** — NestJS IoC container for services, repositories, guards
- **DTO Pattern** — Data Transfer Objects with `class-validator` decorations for input validation
- **Guard Pattern** — `JwtAuthGuard` for route protection
- **Strategy Pattern** — Passport JWT strategy for dual-header token extraction
- **Decorator Pattern** — Custom `@CurrentUser` parameter decorator
- **Observer Pattern** — WebSocket gateway for real-time event handling
- **Message Queue Pattern** — RabbitMQ pub/sub for decoupled notification delivery
- **Repository Pattern** — Mongoose models injected via `@InjectModel`
- **Graceful Degradation** — RabbitMQ failure doesn't crash the app

### Data Structures Used
- **Map** — Connected users tracking in WebSocket gateway (`userId → socketId`)
- **Array** — Interests list, message history, zodiac animals array
- **Queue** — RabbitMQ durable message queue for chat notifications
- **Index** — Compound MongoDB index for optimized message queries
- **Hash** — bcrypt password hashing with salt rounds

---

## Docker Services

| Service | Image | Port | Description |
|---|---|---|---|
| `app` | Custom (Dockerfile) | 3000 | NestJS API server |
| `mongo` | mongo:7 | 27017 | MongoDB database |
| `rabbitmq` | rabbitmq:3-management | 5672, 15672 | Message queue + management UI |

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `MONGODB_URI` | `mongodb://localhost:27017/youapp` | MongoDB connection string |
| `JWT_SECRET` | `youapp-secret-key-2024` | JWT access token signing secret |
| `JWT_EXPIRATION` | `15m` | JWT access token expiration |
| `JWT_REFRESH_SECRET` | `youapp-refresh-secret-2024` | JWT refresh token signing secret |
| `JWT_REFRESH_EXPIRATION` | `7d` | JWT refresh token expiration |
| `RABBITMQ_URI` | `amqp://guest:guest@localhost:5672` | RabbitMQ connection string |
| `PORT` | `3000` | API server port |

---

## Dual-API Compatibility

The app is designed to work with **both** the external YouApp test API (`techtest.youapp.ai`) and our own backend:

| Feature | External API | Our Backend |
|---|---|---|
| Auth header | `x-access-token` | `Authorization: Bearer` |
| Login format | `{ email, username, password }` | `{ usernameOrEmail, password }` |
| JWT userId claim | `id` | `sub` |
| Refresh token | Not provided | Provided |
| Chat endpoints | 404 (not available) | Fully functional |
| User search | Not available | `GET /api/searchUsers` |

**How it works:**
- Frontend sends **both** auth headers on every request
- Backend JWT strategy accepts **both** header formats
- Login DTO accepts **both** `usernameOrEmail` and `email`+`username` fields
- JWT validation checks **both** `sub` and `id` claims
- Chat UI shows clear "Chat Unavailable" message when endpoints return 404

---

## Key Implementation Details

### Security
- Passwords hashed with **bcrypt** (10 salt rounds) — never stored in plaintext
- Dual JWT tokens: short-lived access (15m) + long-lived refresh (7d)
- `ValidationPipe` with `whitelist: true` strips unknown fields from requests
- Password field excluded from all profile responses (`select('-password')`)
- Search results return only public fields (`username`, `name`, `profileImage`)
- CORS enabled for cross-origin requests

### Real-time Chat Flow
1. Client connects to WebSocket and emits `register` with userId
2. Client sends message via REST API (`POST /api/sendMessage`)
3. Backend saves message to MongoDB
4. Backend publishes notification to RabbitMQ queue
5. RabbitMQ consumer picks up notification
6. Consumer emits WebSocket event to receiver's socket
7. Receiver gets real-time `notification` event

### Graceful Degradation
- RabbitMQ connection failure doesn't crash the app — chat works without notification queue
- Frontend handles API errors with user-friendly snackbar messages
- Token expiration auto-redirects to login screen and cleans all stored data
- Profile save uses PUT-first strategy with POST fallback
- GetX bindings use `fenix: true` to safely recreate controllers after logout/re-login

### App Flow
```
Landing → Login/Register → Profile (About + Interest) → Chat
   │                            │                          │
   └── Welcome screen           ├── View/Edit profile      ├── Search users by username
       with Register             │   (name, birthday,       ├── Start new conversation
       & Login buttons           │   height, weight)        ├── Send/receive messages
                                 ├── Auto horoscope/zodiac  └── Real-time via WebSocket
                                 ├── Interest tags
                                 └── Profile card + avatar
```

---

## Scripts Reference

### Backend
| Script | Command | Description |
|---|---|---|
| `npm run start:local` | `nest build && node start-local.js` | Start with in-memory MongoDB (no Docker) |
| `npm run start:dev` | `nest start --watch` | Development with hot-reload |
| `npm run start:prod` | `node dist/main` | Production mode |
| `npm run build` | `nest build` | Compile TypeScript |
| `npm test` | `jest` | Run unit tests |
| `npm run test:cov` | `jest --coverage` | Tests with coverage report |
| `npm run test:e2e` | `jest --config ./test/jest-e2e.json` | End-to-end tests |

### Frontend
| Script | Command | Description |
|---|---|---|
| `flutter run` | — | Run on connected device/emulator |
| `flutter build apk --release` | — | Build release APK |
| `flutter test` | — | Run all tests |
| `flutter analyze` | — | Static analysis |
