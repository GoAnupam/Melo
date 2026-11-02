# Melo
A social dating and discovery platform that helps people meet, connect, and build meaningful relationships through AI-powered matchmaking and interactive experiences.

> **Scope:** mobile app (Flutter, Android + iOS) and REST API (Django) only. There is no web frontend.

## Repository layout

```
mobile/           Flutter app (Dart) — Android & iOS
backend/          Django + Django REST Framework API (PostgreSQL)
infrastructure/   Docker Compose for local services (Postgres); future AWS config
docs/             Project documentation
```

## Prerequisites (macOS)

| Tool | Version | Install |
|---|---|---|
| Homebrew | latest | https://brew.sh |
| Flutter (incl. Dart) | 3.47+ stable | `brew install --cask flutter` |
| JDK | 17 | `brew install openjdk@17` |
| Android SDK | API 35/36 | `brew install --cask android-commandlinetools` (or Android Studio) |
| Xcode + CocoaPods | latest | App Store, then `brew install cocoapods` |
| Python | 3.12 | `brew install python@3.12` |
| PostgreSQL | 16 | `brew install postgresql@16` |
| Docker Desktop | latest | optional, for containerised Postgres |

Add to `~/.zshrc`:

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:/opt/homebrew/opt/postgresql@16/bin:$PATH"
```

One-time Android setup:

```bash
sdkmanager "platform-tools" "platforms;android-35" "platforms;android-36" "build-tools;35.0.0"
sdkmanager --licenses
flutter config --android-sdk "$ANDROID_HOME" --jdk-dir "$JAVA_HOME"
```

One-time iOS setup (after installing Xcode from the App Store):

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS
```

Verify with `flutter doctor`.

## Database

### Option A — Homebrew PostgreSQL (default, port 5432)

```bash
brew services start postgresql@16
psql -d postgres -c "CREATE ROLE melo WITH LOGIN PASSWORD 'melo_dev_password' CREATEDB;"
psql -d postgres -c "CREATE DATABASE melo_dev OWNER melo;"
```

### Option B — Docker (port 5433)

```bash
docker compose -f infrastructure/docker-compose.yml up -d
```

Then set `DATABASE_URL=postgres://melo:melo_dev_password@localhost:5433/melo_dev` in `backend/.env`.

## Backend (Django API)

```bash
cd backend
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env            # then set DJANGO_SECRET_KEY
python manage.py migrate
python manage.py createsuperuser   # optional, for /admin
python manage.py runserver 0.0.0.0:8000
```

- Health check: http://localhost:8000/api/v1/health/
- Run tests: `python manage.py test`

## Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter devices                 # list emulators / simulators / phones
flutter run                     # pick a device
```

Point the app at the API with `--dart-define`:

```bash
# Android emulator (host machine is 10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
# iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

- Static analysis: `flutter analyze`
- Tests: `flutter test`
