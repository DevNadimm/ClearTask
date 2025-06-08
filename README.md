# 💩 ClearTask - To-Do List App

ClearTask is a simple, clean, and powerful task management app built with **Flutter**, using **BLoC** for state management and **SQLite** for local storage. It allows users to manage their daily tasks effectively with optional due dates, categorized types, and notification support.

---

## 🚀 Features

* ✅ Create, update, delete tasks
* 🗕 Optional due date (categorized into Today, Tomorrow, Upcoming, Anytime)
* 🏷 Task types (e.g., Home, Office, Study)
* 🔔 Optional notifications/reminders
* 🧽 Easy navigation with Tabs and Navigation Drawer
* 📊 Completed tasks section
* 🧠 BLoC architecture with SQLite integration
* ☁️ Future support for Firebase sync and user login

---

## 📱 UI Structure

### Tabs:

* All
* Today
* Tomorrow
* Upcoming
* Anytime
* Completed

### Navigation Drawer:

* Home Tasks
* Office Tasks
* Study Tasks
* Settings
* About

---

## 🧱 Architecture

Follows **Clean Architecture** principles with modular separation:

```
lib/
│
├── core/             # Common utilities and services
├── data/             # Models, datasources (SQLite), and repositories
├── domain/           # Entities, use cases, abstract contracts
├── presentation/     # UI screens, widgets, and BLoC states
└── main.dart         # Entry point
```

### 🔁 Data Flow

```
UI → Event (BLoC) → UseCase (domain) → Repository (data) → SQLite → BLoC State → UI
```

---

## 🛠 Tech Stack

| Tech          | Description                     |
| ------------- | ------------------------------- |
| Flutter       | UI Toolkit                      |
| BLoC          | State Management                |
| SQLite        | Local Database (with `sqflite`) |
| Notifications | `flutter_local_notifications`   |
| Firebase      | Planned: Firestore, Auth, Sync  |

---

## 🥪 Planned Features

* 🔄 Firebase Cloud Sync
* 👤 User Authentication
* 🌐 Cross-device data syncing
* 📊 Task priorities (low/medium/high)
* 🧠 Smart task suggestions
* 📊 Analytics & progress stats

---

## 🧑‍💻 Author

**Nadim Chowdhury**

* 🧠 Flutter Developer
* 🎓 CSE, Port City International University
* 🔗 [LinkedIn](https://www.linkedin.com/in/devnadimm/)
* 📬 [nadimchowdhury87@gmail.com](mailto:nadimchowdhury87@gmail.com)
* 💻 [GitHub](https://github.com/DevNadimm)

---

## 📸 Screenshots (Coming Soon...)

Stay tuned for app UI previews!
