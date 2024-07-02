# BKD Scanner

Barcode Scanner by barKoder allows you to extract barcode information from camera video stream or image files. It is a completely free application developed for various uses be that in retail, logistics, warehousing, healthcare and any other industry where barcodes are implemented. The Barcode Scanner by barKoder app is essentially a demo of the capabilities of the barKoder barcode scanner SDK in terms of performance & features.
Integrating the barKoder Barcode Scanner SDK into your Enterprise or Consumer mobile app will instantly transform your user's smartphones & tablets into rugged barcode scanning devices without the need to procure & maintain expensive hardware devices with a short life span.

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)

## Installation

### Prerequisites

- Xcode (latest version recommended)
- CocoaPods (if using pods for dependencies)

### Steps

**Clone the repository**

   ```bash
   git clone https://github.com/barKoderSDK/demo-barkoder-ios
   cd demo-barkoder-ios
   cd BKD\ Scanner/
   ```
**Install dependencies**

```bash
pod install
```

## Configuration

### Add GoogleService-Info.plist

- Obtain your GoogleService-Info.plist file from the Firebase console.
- Add the GoogleService-Info.plist file to your project by dragging it into the Xcode project navigator.

### Update AppConfig

Open AppConfig.swift and update the following properties with your links and license key

```swift
final class AppConfig {
    static let howToUseLink = "https://docs.barkoder.com/en/how-to/demo-app-barKoder"
    static let learnMoreLink = "https://barkoder.com"
    static let termsOfUseLink = "https://barkoder.com/terms-of-use"
    static let testBarcodeLink = "https://barkoder.com/register"
    static let privacyPolicyLink = "https://barkoder.com/privacy-policy"
    static let barkoderLicenseKey = "LICENSE_KEY"
}
```

**Replace LICENSE_KEY with your actual Barkoder license key**

### Update app icon, colors, bundle-id and logo

1. Open ScanAssets.xcassets and update logo and AppIcon
    - Navigate to ScanAssets.xcassets.
    - Replace the existing app icon and logo with your custom images
2. Open ScanColorAssets.xcassets and update brand and accent colors
    - Open ScanColorAssets.xcassets.
    - Modify the brand and accent colors to match your brand's color scheme
3. Update Bundle ID and Display Name
    -   Go to the general settings of your Xcode project
    -   Update the Bundle Identifier to your own unique identifier
    -   Change the Display Name to reflect the name of your app

## Usage

Open the project

1. Open the project workspace (BKD Scanner.xcworkspace) in Xcode:
2. Build and run the project
    -   Select your target device or simulator
    -   Click the build button or use the shortcut Cmd + R to run the app

