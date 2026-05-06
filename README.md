# wheel_of_standup

Spin the wheel of standup! A Flutter web application for managing and spinning a wheel of standup participants.

## Features

- Add and manage standup participants
- Spin the wheel to randomly select a participant
- Persistent storage of participant list
- Web-based, no installation required

## Live Demo

Visit the [live application on GitHub Pages](https://sd-chrallard.github.io/wheel-of-standup/)

## Getting Started

### Prerequisites

- Flutter 3.22.0 or later
- Dart SDK

### Running Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/sd-chrallard/wheel-of-standup.git
   cd wheel-of-standup
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the web app:
   ```bash
   flutter run -d chrome
   ```

4. Open `http://localhost:4567` in your browser

## Building for Production

To build the web app for deployment:

```bash
flutter build web --release --web-renderer html
```

The built files will be in `build/web/`.

## Deployment

This project is automatically deployed to GitHub Pages when you push to the `main` branch. The GitHub Actions workflow (`.github/workflows/deploy.yml`) handles building and deploying the Flutter web app.

### Manual Deployment

If you need to deploy manually, the built `build/web/` directory is what gets served.

## Project Structure

- `lib/` - Dart application code
  - `main.dart` - Application entry point
  - `models/` - Data models
  - `pages/` - Page widgets
  - `services/` - Business logic and storage
  - `state/` - State management
  - `widgets/` - Reusable widgets
- `web/` - Web assets and configuration
- `test/` - Tests

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Dart Documentation](https://dart.dev/)
