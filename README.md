# ⚡ ClearTask - Intelligent & Aesthetic Task Management

ClearTask is a stunning, clean, and powerful task management application built with **Flutter**, designed to help you organize your life with ease. It combines modern design principles with advanced productivity tools like **AI-powered subtask generation**, **Pomodoro timers**, and **Cloud synchronization**.

---

## 🚀 Key Features

*   **🤖 AI-Powered Subtasks**: Break down complex tasks instantly using Google Generative AI (Gemini).
*   **☁️ Cloud Backup & Sync**: Keep your tasks safe and synced across devices with Firebase & Google Sign-In.
*   **⏲️ Pomodoro Timer**: Stay focused and productive with a build-in Pomodoro timer for your tasks.
*   **📝 Rich Text Notes**: Take detailed notes for each task using a powerful rich-text editor (`flutter_quill`).
*   **📈 Analytics Dashboard**: Visualize your productivity trends with detailed completion charts.
*   **📅 Plan My Day**: A dedicated workflow to prioritize and organize your daily schedule.
*   **🎟 AI Usage & Rewards**: Unlock AI features through reward-based interactions using Google Mobile Ads.
*   **🌿 Subtask Management**: Automatic parent-task completion when all subtasks are finished.
*   **🔔 Smart Notifications**: Reliable local reminders that update dynamically based on your schedule.
*   **🎉 Celebration View**: Celebrate your wins with an immersive full-screen animation upon task completion.
*   **🎨 Dynamic Themes**: Seamless Light and Dark mode transitions that adapt to your preferences.

---

## 📱 User Interface

### Smart Task Filtering
*   **Today** - Focus on what's urgent.
*   **Tomorrow** - Plan ahead.
*   **Upcoming** - Long-term goals.
*   **Anytime** - Flexible tasks without deadlines.
*   **Completed** - Review your achievements.

---

## 🧱 Technical Architecture & Stack

ClearTask follows **Clean Architecture** principles to separate concerns and ensure maintainability.

### Core Stack:
| Technology | Purpose |
| ---------- | ------- |
| **Flutter** | Cross-platform UI Toolkit |
| **BLoC/Cubit** | Advanced State Management & Logic |
| **GetX** | Routing, Overlays, and Snackbars |
| **Firebase** | Authentication & Cloud Synchronization |
| **Gemini AI** | Intelligent Subtask Generation |
| **SQLite (sqflite)**| Persistent Local Storage (Offline-first) |
| **Google Ads** | Monetization & Feature Unlocks |
| **FL Chart** | Data Visualization & Analytics |

### Module Structure:
```
lib/
├── core/             # Themes, Services, Utils, and Global Widgets
├── data/             # Models, Repositories, and Data Sources (SQLite/Firebase)
├── presentation/     # Screens, Widgets, and BLoCs/Cubits
└── main.dart         # App Entry & Initialization
```

---

## 🚧 Future Roadmap

*   📅 **Calendar Integration**: Google & Apple Calendar sync for scheduling.
*   👥 **Collaborative Tasks**: Share task lists with friends or colleagues.
*   🏷 **Voice Input**: Create tasks using AI-powered voice commands.
*   ⌚ **Smartwatch Support**: Manage tasks from your wrist (WearOS/watchOS).

---

## 🧑‍💻 Author

**Nadim Chowdhury**

*   🧠 Passionate Flutter Developer
*   🎓 BSc in CSE, Port City International University
*   🔗 [LinkedIn](https://www.linkedin.com/in/devnadimm/)
*   📬 [nadimm.dev@gmail.com](mailto:nadimchowdhury87@gmail.com)
*   💻 [GitHub](https://github.com/DevNadimm)
