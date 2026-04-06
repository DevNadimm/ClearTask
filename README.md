# ⚡ ClearTask: AI Planner & ToDo

ClearTask is a premium, AI-driven task management application that transforms productivity into a rewarding journey. Built with **Flutter**, it combines cutting-edge AI planning with an immersive **RPG-style economy** to help you conquer your day, one task at a time.

---

## 🤖 AI-First Productivity

ClearTask leverages advanced Large Language Models to act as your personal executive assistant.

*   **📅 Plan My Day**: Analyzes your pending tasks, priorities, and deadlines to generate a smart, time-blocked schedule. Powered by **Gemini 1.5 Flash** with **Groq (Llama 3.3 70B)** fallback.
*   **🧩 AI Subtask Generation**: Instantly breaks down complex goals into manageable, actionable steps.
*   **🧠 Context-Aware Logic**: Intelligent categorization and prioritization that adapts to your unique workflow.

---

## 🎮 The Productivity RPG (Clear Economy)

Turn your to-do list into a level-up experience. Stay productive to earn rewards and unlock premium features.

*   **💰 Clear Coins & XP**: Earn coins and experience points for every task you complete and ogni daily login.
*   **🏆 Leveling System**: Move up the ranks as you accumulate XP. From "Newbie" to "Productivity Master".
*   **💳 User Wallet**: A centralized hub to track your earnings, bonuses, and feature unlocks.
*   **🎁 Engagement Bonuses**: Get rewarded for consistency with signup bonuses and daily rewards.

---

## 🚀 Key Features

*   **☁️ Cloud Sync & Backup**: Secure your data with Firebase Firestore and Google Sign-In.
*   **🗓️ Google Calendar**: Bidirectional synchronization to keep your schedule aligned.
*   **⏲️ Pomodoro Focus**: Integrated focus timer to maximize deep work sessions.
*   **📈 Advanced Analytics**: Visualize your productivity trends with interactive completion charts.
*   **✍️ Rich Text Notes**: Take detailed documentation for any task using `flutter_quill`.
*   **🔔 Smart Notifications**: Dynamic, schedule-aware reminders that keep you on track.
*   **🏗️ Parent-Instance Model**: Advanced architecture for complex task dependencies.
*   **🎉 Celebration Dialog**: Celebrate your wins with an interactive dialog and immersive sound effects upon completion.

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
| **AI Models** | Intelligent Planning (Gemini & Groq) & Subtask Generation |
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

## 🧑‍💻 Author

**Nadim Chowdhury**

*   🧠 Passionate Flutter Developer
*   🎓 BSc in CSE, Port City International University
*   🔗 [LinkedIn](https://www.linkedin.com/in/devnadimm/)
*   📬 [nadimm.dev@gmail.com](mailto:nadimm.dev@gmail.com)
*   💻 [GitHub](https://github.com/DevNadimm)

---

> [!TIP]
> This application is constantly evolving. Keep an eye on our [Issues](https://github.com/DevNadimm/clear_task/issues) for upcoming features!
