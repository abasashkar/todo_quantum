# Todo Task

A Flutter ToDo application built for a developer assessment. It demonstrates **clean architecture**, **BLoC state management**, **GetIt dependency injection**, **offline-first Hive storage**, and **local notifications** for task reminders.

## Features

### Core requirements
- Add, edit, and delete tasks
- Mark tasks as completed / reopen completed tasks
- Task fields: title, description, priority, due date
- Search tasks by title or description
- Filter tasks: All, Active, Completed, High Priority, Due Today, Overdue
- Offline storage with Hive
- Local notifications for due-date reminders

### Bonus
- Dark mode toggle (persisted in Hive)
- Unit tests for filtering logic and BLoC

## Architecture

The project follows a feature-based clean architecture:

```
lib/
├── main.dart
├── app.dart
├── injection_container.dart          # GetIt setup
├── core/
│   ├── constants/
│   ├── enums/
│   ├── services/                     # Notifications, settings
│   ├── theme/
│   └── utils/
└── features/todo/
    ├── domain/                       # Entities + repository contracts
    ├── data/                         # Hive models, datasource, repository impl
    └── presentation/                 # BLoC, pages, widgets
```

### Layers
| Layer | Responsibility |
|-------|----------------|
| **Domain** | `Task` entity and `TaskRepository` contract |
| **Data** | Hive persistence, `TaskRepositoryImpl`, notification scheduling |
| **Presentation** | `TodoBloc`, UI pages, widgets |
| **Core** | Shared theme, enums, notification service, DI helpers |

### State management
`TodoBloc` handles:
- Loading and persisting tasks
- Search and filter state
- Theme mode persistence
- Task CRUD and completion toggling

## Tech stack

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection |
| `hive` / `hive_flutter` | Offline local database |
| `flutter_local_notifications` | Due-date reminders |
| `timezone` | Scheduled notification times |
| `equatable` | Value equality for states/events |
| `uuid` | Task IDs |
| `intl` | Date formatting |

## Setup

### Prerequisites
- Flutter SDK `>=3.6.0`
- Xcode (iOS) or Android Studio (Android)

### Install and run

```bash
git clone <your-repo-url>
cd todotask
flutter pub get
flutter run
```

### Run tests

```bash
flutter test
flutter analyze
```

## Usage

1. Tap **Add Task** to create a task with title, description, priority, due date, and reminder.
2. Tap a task card to edit it.
3. Use the checkbox to complete or reopen a task.
4. Use the search bar and filter chips to find tasks.
5. Toggle dark mode from the header.
6. When a due date and reminder are set, a local notification fires at the due time.

## Notifications

- Android 13+ requests the `POST_NOTIFICATIONS` permission at startup.
- Reminders are scheduled when a task has a due date and **Enable reminder** is on.
- Reminders are cancelled when a task is completed or deleted.

## Demo

Add screenshots or a short screen recording showing:
- Creating a task with all fields
- Searching and filtering
- Completing a task
- Receiving a reminder notification
- Dark mode

## Project structure decisions

- **Hive over SharedPreferences** for structured offline task storage and better scalability.
- **Repository pattern** keeps persistence and notification side effects out of the UI layer.
- **GetIt** centralizes dependency wiring in `injection_container.dart`.
- **TaskFilterHelper** isolates search/filter logic for easy unit testing.

## License

This project was created as a Flutter developer assessment submission.
