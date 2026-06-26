# SocialBox

Organize, schedule, and track your social media content.

**Package:** `com.linkedif.socialbox`  
**Stack:** Flutter · Features-First Clean Architecture · MVVM · BLoC/Cubit · Drift · GoRouter

## Documentation

| File | Purpose |
|------|---------|
| [CLAUDE.md](CLAUDE.md) | Full architecture spec |
| [quickref.md](quickref.md) | One-page cheat sheet |
| [features.md](features.md) | Feature inventory |
| [STATUS.md](STATUS.md) | Session state and gaps |
| [agents.md](agents.md) | Developer / agent workflow |

## Build (Windows, project on `I:` drive)

```powershell
$env:PUB_CACHE = "I:\.pub-cache"
Set-Location I:\Posts\socialbox
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d <device_id>
```

## Architecture

```
View (pages/widgets) → ViewModel (Bloc/Cubit) → UseCase → Repository → DataSource
```

Features live under `lib/features/{name}/` with `data/`, `domain/`, `presentation/` layers.