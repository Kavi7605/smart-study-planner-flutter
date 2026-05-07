# Smart Study Planner & Exam Preparation Tracker

A complete Flutter application for students to plan study schedules, track syllabus completion, and monitor exam preparation progress.

---

## 📁 Complete Project Structure

```
smart_study_planner/
├── pubspec.yaml
├── android/
│   └── app/
│       └── build.gradle
└── lib/
    ├── main.dart
    ├── models/
    │   ├── subject_model.dart
    │   ├── subject_model.g.dart        ← Hive adapter (pre-generated)
    │   ├── topic_model.dart
    │   ├── topic_model.g.dart          ← Hive adapter (pre-generated)
    │   ├── study_session_model.dart
    │   └── study_session_model.g.dart  ← Hive adapter (pre-generated)
    ├── providers/
    │   ├── subject_provider.dart
    │   └── session_provider.dart
    ├── screens/
    │   ├── main_shell.dart
    │   ├── dashboard_screen.dart
    │   ├── subject_management_screen.dart
    │   ├── schedule_screen.dart
    │   ├── progress_screen.dart
    │   └── search_screen.dart
    ├── services/
    │   ├── hive_service.dart
    │   └── dummy_data.dart
    ├── utils/
    │   ├── app_theme.dart
    │   └── helpers.dart
    └── widgets/
        ├── stat_card.dart
        ├── subject_progress_card.dart
        ├── topic_list_item.dart
        └── session_card.dart
```

---

## ✅ Features

| Feature | Description |
|---|---|
| Dashboard | Stats, pie chart, subject progress bars, upcoming sessions |
| Subjects | Add/delete subjects with custom colors |
| Topics | Add topics with estimated time under subjects |
| Status | Mark topics as Not Started / In Progress / Completed |
| Scheduling | Schedule study sessions with date, time, duration |
| Progress | Circular progress per subject + status toggles |
| Search | Live search + filter by subject & status |
| Offline | All data stored in Hive (works offline) |
| Sample Data | 4 subjects, 15 topics, 3 sessions loaded on first run |

---

## 🛠️ Step-by-Step Setup Instructions

### Prerequisites
- Flutter SDK 3.x installed
- Android Studio or VS Code with Flutter extension
- Android emulator or physical device (Android 5.0+)

---

### Step 1: Create Flutter Project

Open terminal and run:
```bash
flutter create smart_study_planner
cd smart_study_planner
```

---

### Step 2: Replace pubspec.yaml

Replace the entire content of `pubspec.yaml` with the provided file.

Then run:
```bash
flutter pub get
```

---

### Step 3: Create Folder Structure

Inside `lib/`, create these folders:
```
lib/models/
lib/providers/
lib/screens/
lib/services/
lib/utils/
lib/widgets/
```

In Android Studio: right-click `lib` → New → Package

---

### Step 4: Paste All Files

Copy each file into the correct location:

**Models (lib/models/):**
- `subject_model.dart`
- `subject_model.g.dart`
- `topic_model.dart`
- `topic_model.g.dart`
- `study_session_model.dart`
- `study_session_model.g.dart`

**Providers (lib/providers/):**
- `subject_provider.dart`
- `session_provider.dart`

**Screens (lib/screens/):**
- `main_shell.dart`
- `dashboard_screen.dart`
- `subject_management_screen.dart`
- `schedule_screen.dart`
- `progress_screen.dart`
- `search_screen.dart`

**Services (lib/services/):**
- `hive_service.dart`
- `dummy_data.dart`

**Utils (lib/utils/):**
- `app_theme.dart`
- `helpers.dart`

**Widgets (lib/widgets/):**
- `stat_card.dart`
- `subject_progress_card.dart`
- `topic_list_item.dart`
- `session_card.dart`

**Root:**
- Replace `lib/main.dart`

---

### Step 5: Run the App

```bash
# Check for issues
flutter analyze

# Run on connected device or emulator
flutter run
```

Or press the **Run** button in Android Studio (Shift+F10).

---

## 🎮 How to Use the App

1. **Dashboard** — See overview stats, chart, and upcoming sessions
2. **Subjects tab** — Add a subject → Tap `+` icon to add topics inside it
3. **Topics** — Tap the status icon to cycle: Not Started → In Progress → Completed
4. **Schedule tab** — Tap FAB → Pick subject, topic, date/time, duration
5. **Progress tab** — See circular progress per subject; tap "View Topics" to change status
6. **Search tab** — Type to search topics; use dropdowns to filter by subject/status

---

## 📦 Dependencies Used

| Package | Version | Purpose |
|---|---|---|
| provider | ^6.1.1 | State management |
| hive | ^2.2.3 | Local offline database |
| hive_flutter | ^1.1.0 | Hive + Flutter integration |
| percent_indicator | ^4.2.3 | Progress bars & circular indicators |
| fl_chart | ^0.66.2 | Pie chart on dashboard |
| google_fonts | ^6.1.0 | Poppins font |
| intl | ^0.19.0 | Date formatting |
| flutter_slidable | ^3.0.1 | Swipe-to-delete |

---

## 🔧 Troubleshooting

**"Hive adapter already registered"**
→ This means Hive adapters are registered twice. Check that `HiveService.init()` is called only once in `main.dart`.

**Build errors with .g.dart files**
→ The `.g.dart` files are pre-written manually — you do NOT need to run `build_runner`. Just paste them as-is.

**Cannot find package**
→ Run `flutter pub get` again after editing `pubspec.yaml`.

**App shows blank screen**
→ Make sure `main.dart` has `WidgetsFlutterBinding.ensureInitialized()` before `HiveService.init()`.

---

## 📱 Screenshots (App Screens)

1. **Dashboard** — Greeting, 4 stat cards, pie chart, subject progress, upcoming sessions
2. **Subjects** — Accordion cards with expandable topics list
3. **Schedule** — Upcoming / All sessions with bottom sheet to add new
4. **Progress** — Circular progress + three-button status selector per topic
5. **Search** — Live search with subject & status filters

---

*Built for MAD (Mobile Application Development) Practical Exam | Flutter + Provider + Hive*
