# TON Blocks - Flutter Blockchain Explorer

A modern Flutter application for exploring the TON (The Open Network) blockchain using TON Console API.

## Features

### 🏠 Home Interface
- **Crypto-themed Dark UI**: Modern dark theme with gradient cards and crypto-focused design
- **Wallet Search**: Search for TON wallet addresses with real-time validation
- **Transaction Explorer**: View recent transactions with detailed information
- **Block Explorer**: Monitor latest blockchain blocks
- **Responsive Design**: Optimized for mobile, tablet, and desktop devices

### 🔧 Technical Features
- **GetX State Management**: Reactive state management with GetX
- **Responsive Framework**: Multi-device support with flutter_screenutil and responsive_framework
- **TON Console API Integration**: Real-time blockchain data fetching
- **Modern UI Components**: Custom gradient cards, shimmer loading, and smooth animations
- **Error Handling**: Comprehensive error handling and user feedback

## Technology Stack

- **Framework**: Flutter 3.7.2+
- **State Management**: GetX 4.6.6
- **HTTP Client**: Dio 5.4.0
- **Responsive Design**: 
  - flutter_screenutil 5.9.0
  - responsive_framework 1.5.1
- **UI Enhancements**:
  - google_fonts 6.2.1
  - flutter_staggered_animations 1.1.1
  - shimmer 3.0.0
  - font_awesome_flutter 10.6.0

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart         # App theme configuration
│   ├── data/
│   │   ├── models/
│   │   │   └── transaction_model.dart # Data models
│   │   └── services/
│   │       └── ton_api_service.dart   # TON API service
│   ├── modules/
│   │   ├── home/                      # Home module
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── transactions/              # Transactions module
│   │   └── transaction_detail/        # Transaction detail module
│   ├── routes/
│   │   ├── app_pages.dart            # Route definitions
│   │   └── app_routes.dart           # Route constants
│   └── shared/
│       └── widgets/
│           └── common_widgets.dart    # Reusable widgets
```

## Getting Started

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   # For web
   flutter run -d chrome
   
   # For desktop
   flutter run -d windows
   
   # For mobile (with device connected)
   flutter run
   ```

## Demo Addresses

The app includes demo TON addresses for testing:
- `EQD4FPq-PRDieyQKkizFTRtSDyucUIqrj0v_zXJmqaDp6_0t`
- `EQBvW8Z5huBkMJYdnfAEM5JqTNkuWX3diqYENkWsIL0XggGG`
- `EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs`

**Built with ❤️ using Flutter and GetX**
