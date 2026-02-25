# YouApp - Fullstack Social Profile & Chat Application

A fullstack application consisting of a **Flutter mobile app** (frontend) and a **NestJS REST API** (backend) with real-time chat capabilities. Users can register, login, manage their profile (including horoscope & zodiac calculation), and chat with other users in real-time via WebSocket with RabbitMQ message notification.

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
| GoogleFonts | 6.2.1 | Typography |

### Backend
| Technology | Version | Purpose |
|---|---|---|
| NestJS | 11.x | Node.js framework |
| MongoDB | 7.x | NoSQL database |
| Mongoose | 9.2.2 | MongoDB ODM |
| JWT (Passport) | 11.x | Authentication |
| Socket.io | 4.8.3 | Real-time WebSocket |
| RabbitMQ (amqplib) | 0.10.9 | Message queue notifications |
| Swagger | 11.x | API documentation |
| Docker | - | Containerization |
| bcrypt | 6.0.0 | Password hashing |
| class-validator | 0.14.3 | DTO validation |

---

## Architecture

### Frontend Architecture
```
Clean Architecture with GetX Pattern
├── app/              → Bindings, Routes (DI & navigation config)
├── core/             → Constants, Network (API client), Theme
├── data/             → Models, Providers (API calls), Repositories
├── modules/          → Feature modules (auth, profile, chat)
│   └── feature/
│       ├── controllers/  → Business logic (GetxController)
│       ├── views/        → UI screens (GetView)
│       └── widgets/      → Feature-specific widgets
└── widgets/          → Shared/common widgets
```

### Backend Architecture
```
NestJS Modular Architecture
├── auth/             → Authentication module
│   ├── controllers/  → REST endpoints
│   ├── services/     → Business logic
│   ├── dto/          → Data Transfer Objects with validation
│   ├── guards/       → JWT auth guard
│   └── strategies/   → Passport JWT strategy
├── users/            → Profile management module
│   ├── controllers/  → CRUD endpoints
│   ├── services/     → Profile business logic
│   ├── dto/          → Profile DTOs
│   └── schemas/      → MongoDB schemas
├── chat/             → Chat module
│   ├── controllers/  → REST endpoints
│   ├── services/     → Message business logic
│   ├── gateway/      → WebSocket gateway (Socket.io)
│   ├── rabbitmq/     → RabbitMQ notification service
│   ├── dto/          → Message DTOs
│   └── schemas/      → Message schema
└── common/           → Shared utilities
    ├── decorators/   → Custom decorators (@CurrentUser)
    └── utils/        → Horoscope & Zodiac calculation
```

### System Architecture Diagram
```
┌──────────────────────────────────────────────────────────────────┐
│                        Flutter Mobile App                        │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │   Auth   │  │   Profile    │  │     Chat     │              │
│  │  Module   │  │    Module    │  │    Module     │              │
│  └────┬─────┘  └──────┬───────┘  └──────┬───────┘              │
│       │               │                 │                       │
│       └───────────────┼─────────────────┘                       │
│                       │ Dio HTTP Client                         │
│                       │ (x-access-token)                        │
└───────────────────────┼─────────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────────────┐
│                      NestJS Backend API                           │
│  ┌─────────────┐  ┌───────────────┐  ┌─────────────────────┐    │
│  │ Auth Module  │  │ Users Module  │  │    Chat Module      │    │
│  │ /api/login   │  │ /api/profile  │  │ /api/sendMessage    │    │
│  │ /api/register│  │ CRUD          │  │ /api/viewMessages   │    │
│  └──────┬──────┘  └───────┬───────┘  │ WebSocket Gateway   │    │
│         │                 │          └──────┬──────────────┘    │
│         │                 │                 │                    │
│   ┌─────▼─────────────────▼─────┐    ┌──────▼──────────┐       │
│   │       MongoDB (Mongoose)     │    │   RabbitMQ      │       │
│   │  ┌────────┐  ┌───────────┐  │    │  Notification   │       │
│   │  │ Users  │  │ Messages  │  │    │    Queue        │       │
│   │  └────────┘  └───────────┘  │    └─────────────────┘       │
│   └─────────────────────────────┘                               │
└───────────────────────────────────────────────────────────────────┘
```

---

## Features

### Authentication
- User registration with email, username, and password
- Login with email (JWT token-based)
- Login supports `$or` query matching (email or username) on the custom backend
- Password hashing with bcrypt (10 salt rounds)
- JWT token with configurable expiration (default: 7 days)
- Auto-redirect to login on token expiration (401 handler)
- Persistent session via SharedPreferences

### Profile Management
- Create, read, and update user profile
- Profile fields: display name, gender, birthday, height, weight, interests
- Automatic **horoscope** calculation based on birthday (Western zodiac signs)
- Automatic **Chinese zodiac** calculation based on birth year
- Profile image selection (camera or gallery)
- Interest tags with add/remove functionality
- Real-time UI updates on save (reactive state with GetX)

### Chat System
- REST API for sending and viewing messages
- Real-time messaging via **Socket.io** WebSocket gateway
- **RabbitMQ** message notification queue
  - Publisher: sends notification when a message is created
  - Consumer: receives notifications and forwards via WebSocket
- Message read status tracking (`isRead` flag)
- Unread message count
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
├── frontend/                    # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── app/
│   │   │   ├── bindings/        # GetX dependency injection
│   │   │   │   ├── auth_binding.dart
│   │   │   │   ├── chat_binding.dart
│   │   │   │   └── profile_binding.dart
│   │   │   └── routes/
│   │   │       ├── app_pages.dart   # Route-to-page mapping
│   │   │       └── app_routes.dart  # Route constants
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   └── api_constants.dart  # API URLs & storage keys
│   │   │   ├── network/
│   │   │   │   └── api_client.dart     # Dio HTTP client + interceptors
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
│   │   │       └── chat_provider.dart      # Chat API calls
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   │   ├── controllers/auth_controller.dart
│   │   │   │   └── views/
│   │   │   │       ├── landing_view.dart   # Welcome screen
│   │   │   │       ├── login_view.dart     # Login form
│   │   │   │       └── register_view.dart  # Registration form
│   │   │   ├── profile/
│   │   │   │   ├── controllers/profile_controller.dart
│   │   │   │   └── views/
│   │   │   │       ├── profile_view.dart       # Profile display + edit
│   │   │   │       ├── edit_profile_view.dart  # Dedicated edit screen
│   │   │   │       └── interests_view.dart     # Interest tag editor
│   │   │   └── chat/
│   │   │       ├── controllers/chat_controller.dart
│   │   │       └── views/
│   │   │           ├── chat_list_view.dart  # Conversation list
│   │   │           └── chat_room_view.dart  # Chat messages
│   │   └── widgets/
│   │       └── common_widgets.dart  # Shared UI components
│   ├── test/
│   │   ├── unit/                    # Unit tests
│   │   │   ├── api_constants_test.dart
│   │   │   └── user_model_test.dart
│   │   └── widget/                  # Widget tests
│   │       ├── common_widgets_test.dart
│   │       ├── login_view_test.dart
│   │       └── register_view_test.dart
│   ├── integration_test/
│   │   └── app_test.dart            # Integration tests
│   └── pubspec.yaml
│
├── backend/                     # NestJS API server
│   ├── src/
│   │   ├── main.ts              # Bootstrap (CORS, validation, Swagger)
│   │   ├── app.module.ts        # Root module
│   │   ├── auth/
│   │   │   ├── auth.controller.ts     # POST /api/register, /api/login
│   │   │   ├── auth.service.ts        # Register (bcrypt), Login ($or query)
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.service.spec.ts   # Unit tests (14 tests)
│   │   │   ├── dto/
│   │   │   │   ├── login.dto.ts       # email, username, password
│   │   │   │   └── register.dto.ts    # @IsEmail, @MinLength(6)
│   │   │   ├── guards/
│   │   │   │   └── jwt-auth.guard.ts
│   │   │   └── strategies/
│   │   │       └── jwt.strategy.ts    # Passport JWT extraction
│   │   ├── users/
│   │   │   ├── users.controller.ts    # CRUD profile endpoints
│   │   │   ├── users.service.ts       # Profile business logic
│   │   │   ├── users.module.ts
│   │   │   ├── users.service.spec.ts  # Unit tests (8 tests)
│   │   │   ├── dto/
│   │   │   │   └── profile.dto.ts     # CreateProfileDto, UpdateProfileDto
│   │   │   └── schemas/
│   │   │       └── user.schema.ts     # MongoDB user schema
│   │   ├── chat/
│   │   │   ├── chat.controller.ts     # sendMessage, viewMessages
│   │   │   ├── chat.service.ts        # Message CRUD + read status
│   │   │   ├── chat.module.ts
│   │   │   ├── chat.service.spec.ts   # Unit tests (4 tests)
│   │   │   ├── dto/
│   │   │   │   └── message.dto.ts     # SendMessageDto
│   │   │   ├── gateway/
│   │   │   │   └── chat.gateway.ts    # Socket.io WebSocket gateway
│   │   │   ├── rabbitmq/
│   │   │   │   └── rabbitmq.service.ts # RabbitMQ pub/sub service
│   │   │   └── schemas/
│   │   │       └── message.schema.ts  # MongoDB message schema
│   │   └── common/
│   │       ├── decorators/
│   │       │   └── current-user.decorator.ts  # @CurrentUser param decorator
│   │       └── utils/
│   │           ├── horoscope.util.ts          # Horoscope & Zodiac functions
│   │           └── horoscope.util.spec.ts     # Unit tests (3 tests)
│   ├── test/
│   │   ├── app.e2e-spec.ts      # E2E test
│   │   └── jest-e2e.json
│   ├── docker-compose.yml       # Docker services config
│   ├── Dockerfile               # Node.js production image
│   ├── .env                     # Environment variables
│   ├── package.json
│   └── tsconfig.json
│
└── README.md                    # This file
```

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
| `POST` | `/api/login` | No | Login and receive JWT token |

**Register** `POST /api/register`
```json
{
  "email": "john@example.com",
  "username": "johndoe",
  "password": "password123"
}
```
Response `201`:
```json
{
  "message": "User has been created successfully"
}
```

**Login** `POST /api/login`
```json
{
  "email": "john@example.com",
  "username": "johndoe",
  "password": "password123"
}
```
Response `200`:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

> Login uses `$or` query — matches either email or username field.

#### Profile

All profile endpoints require `x-access-token` header.

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/api/createProfile` | JWT | Create user profile |
| `GET` | `/api/getProfile` | JWT | Get current user profile |
| `PUT` | `/api/updateProfile` | JWT | Update user profile |

**Create/Update Profile** `POST /api/createProfile` or `PUT /api/updateProfile`
```json
{
  "name": "John Doe",
  "gender": "Male",
  "birthday": "1995-08-17",
  "height": 175,
  "weight": 70,
  "interests": ["Music", "Sports", "Travel"]
}
```
Response — returns the full user profile with auto-computed `horoscope` and `zodiac`:
```json
{
  "_id": "...",
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

#### Chat

All chat endpoints require `x-access-token` header.

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/api/sendMessage` | JWT | Send a message to another user |
| `GET` | `/api/viewMessages?receiverId=<id>` | JWT | View conversation with a user |

**Send Message** `POST /api/sendMessage`
```json
{
  "receiverId": "507f1f77bcf86cd799439011",
  "content": "Hello, how are you?"
}
```

**View Messages** `GET /api/viewMessages?receiverId=507f1f77bcf86cd799439011`

Response `200`:
```json
{
  "data": [
    {
      "_id": "...",
      "senderId": { "_id": "...", "username": "johndoe", "name": "John" },
      "receiverId": { "_id": "...", "username": "jane", "name": "Jane" },
      "content": "Hello!",
      "isRead": true,
      "createdAt": "2025-01-01T00:00:00.000Z"
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

## Getting Started

### Prerequisites
- **Node.js** >= 20.x
- **Docker** & **Docker Compose**
- **Flutter** >= 3.x (Dart >= 3.11)
- **Android SDK** (for mobile build)

### Backend Setup

#### Option 1: Docker (Recommended)
```bash
cd backend

# Start all services (API + MongoDB + RabbitMQ)
docker-compose up -d

# API will be available at http://localhost:3000
# Swagger docs at http://localhost:3000/api-docs
# RabbitMQ management UI at http://localhost:15672 (guest/guest)
```

#### Option 2: Manual
```bash
cd backend

# Install dependencies
npm install

# Create .env file (or use existing)
# MONGODB_URI=mongodb://localhost:27017/youapp
# JWT_SECRET=youapp-secret-key-2024
# JWT_EXPIRATION=7d
# RABBITMQ_URI=amqp://guest:guest@localhost:5672
# PORT=3000

# Make sure MongoDB and RabbitMQ are running locally

# Start in development mode
npm run start:dev
```

### Frontend Setup

```bash
cd frontend

# Get Flutter dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

#### API Configuration

The API base URL is configured in `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
  static const String baseUrl = 'https://techtest.youapp.ai';
  // Change to your backend URL for local development:
  // static const String baseUrl = 'http://10.0.2.2:3000';  // Android emulator
  // static const String baseUrl = 'http://192.168.x.x:3000'; // Physical device
}
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

**Test Results: 29 tests across 4 suites**
```
PASS  src/chat/chat.service.spec.ts          (4 tests)
PASS  src/users/users.service.spec.ts        (8 tests)
PASS  src/common/utils/horoscope.util.spec.ts (3 tests)
PASS  src/auth/auth.service.spec.ts          (14 tests)

Test Suites: 4 passed, 4 total
Tests:       29 passed, 29 total
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

---

## Design Patterns & Architecture Patterns

### Frontend
- **Clean Architecture** — Separation of data, domain, and presentation layers
- **Repository Pattern** — Providers abstract API communication from controllers
- **Observer Pattern** — GetX reactive state (`Rx`, `Obx`) for automatic UI updates
- **Dependency Injection** — GetX `Bindings` for lazy controller initialization
- **MVC Variant** — Controllers handle logic, Views handle UI, Models represent data
- **Singleton Pattern** — API client shared across providers

### Backend
- **Modular Architecture** — NestJS modules (auth, users, chat) with clear boundaries
- **Dependency Injection** — NestJS IoC container for services, repositories, guards
- **DTO Pattern** — Data Transfer Objects with `class-validator` decorations for input validation
- **Guard Pattern** — `JwtAuthGuard` for route protection
- **Strategy Pattern** — Passport JWT strategy for token extraction and validation
- **Decorator Pattern** — Custom `@CurrentUser` parameter decorator
- **Observer Pattern** — WebSocket gateway for real-time event handling
- **Message Queue Pattern** — RabbitMQ pub/sub for decoupled notification delivery
- **Repository Pattern** — Mongoose models injected via `@InjectModel`

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
| `JWT_SECRET` | `youapp-secret-key-2024` | JWT signing secret |
| `JWT_EXPIRATION` | `7d` | JWT token expiration |
| `RABBITMQ_URI` | `amqp://guest:guest@localhost:5672` | RabbitMQ connection string |
| `PORT` | `3000` | API server port |

---

## App Screenshots Flow

```
Landing → Login/Register → Profile (About + Interest) → Chat
   │                            │
   └── Welcome screen           ├── View/Edit display name, birthday,
       with Register             │   height, weight, gender
       & Login buttons           ├── Auto-computed horoscope & zodiac
                                 ├── Interest tags (add/remove)
                                 └── Profile card with avatar
```

---

## Key Implementation Details

### Security
- Passwords hashed with **bcrypt** (10 salt rounds) — never stored in plaintext
- JWT tokens with configurable expiration
- `ValidationPipe` with `whitelist: true` strips unknown fields from requests
- Password field excluded from all profile responses (`select('-password')`)
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
- Token expiration auto-redirects to login screen
- Profile save uses PUT-first strategy with POST fallback
