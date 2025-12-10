# Big Feelings

An iOS app designed to help children ages 4-12 explore and understand their emotions through interactive stories, quizzes, and journaling activities.

## Overview

Big Feelings is an educational app that uses storytelling and interactive activities to help children develop emotional intelligence. The app features age-appropriate content, progress tracking, and a safe, private environment for children to express and understand their feelings.

## Development Methodology

**Note**: This app is being developed by professional full stack engineers using an AI-assisted development approach. We utilize swarms of AI agents to write code, typically through [Cursor IDE](https://cursor.sh), while maintaining manual code review and oversight. All code is carefully reviewed by human engineers before being merged, ensuring quality and maintainability. This hybrid approach allows us to leverage AI capabilities for rapid development while maintaining professional engineering standards.

## Features

- **Interactive Stories**: Engaging stories featuring animal characters facing real emotional situations
- **Age-Appropriate Content**: Stories tailored for three age groups (4-6, 7-9, and 10-12)
- **Feelings Journal**: Daily check-ins to help children express how they're feeling
- **Progress Tracking**: View emotional growth over time with stats and analytics
- **Achievement System**: Fun rewards for completing stories and activities
- **Quiz System**: Interactive quizzes to reinforce emotional learning
- **Multiple Child Profiles**: Support for tracking multiple children's progress
- **Safe & Private**: All data stored locally on device - no tracking, no ads

## Tech Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Minimum iOS Version**: iOS 17.0
- **Architecture**: MVVM-like pattern with Managers for business logic
- **Data Storage**: UserDefaults (local storage only)
- **Dependencies**: None (pure Swift/SwiftUI)

## Requirements

### Development Environment

- **macOS**: Latest version recommended (for Xcode)
- **Xcode**: Version 15.0 or later
- **iOS SDK**: iOS 17.0+
- **Swift**: 5.0+

### Runtime Requirements

- **iOS**: 17.0 or later
- **Device**: iPhone (iPad support may vary)
- **Internet**: Not required (fully offline app)

## Getting Started

### Prerequisites

1. Install [Xcode](https://developer.apple.com/xcode/) from the Mac App Store
2. Ensure you have an Apple Developer account (free account works for development)
3. Clone this repository

### Setup

1. **Open the project**:
   ```bash
   cd bigfeelings
   open bigfeelings.xcodeproj
   ```

2. **Configure signing**:
   - Open the project in Xcode
   - Select the `bigfeelings` target
   - Go to "Signing & Capabilities"
   - Select your development team
   - Ensure "Automatically manage signing" is enabled

3. **Select a simulator or device**:
   - Choose an iOS 17.0+ simulator from the device dropdown
   - Or connect a physical device (iPhone 12 or newer)

4. **Build and run**:
   - Press `Cmd + R` or click the Run button
   - The app should launch in the simulator/device

### First Launch

On first launch, the app will:
1. Show the welcome screen
2. Prompt you to add a child profile
3. Allow you to select an age range
4. Navigate to the stories list

## Development Workflow

### Running the App

```bash
# Open in Xcode
open bigfeelings.xcodeproj

# Or use xcodebuild from command line
xcodebuild -project bigfeelings.xcodeproj -scheme bigfeelings -sdk iphonesimulator
```

### Testing

The project includes test targets:
- `bigfeelingsTests`: Unit tests
- `bigfeelingsUITests`: UI tests

Run tests with `Cmd + U` in Xcode.

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Keep views focused and composable
- Use meaningful variable and function names
- Add comments for complex logic

## Key Components

### Data Models

- **Child**: Represents a child profile with name, age, and notes
- **Story**: Interactive story with choices and emotional themes
- **QuizSession**: Tracks quiz attempts and results
- **FeelingsJournalEntry**: Journal entries for daily check-ins
- **Achievement**: Achievement definitions and progress tracking

### Managers

- **UserDefaultsManager**: Handles all local data persistence
- **AchievementManager**: Manages achievement progress and unlocking
- **StoryLoader**: Loads and parses story data from JSON
- **QuizSummaryGenerator**: Generates summaries from quiz results

### Data Storage

All data is stored locally using `UserDefaults`:
- Child profiles
- Story progress
- Quiz sessions
- Journal entries
- Achievements
- Streaks and activity data

**Note**: When a child is deleted, all associated data (achievements, stats, journal entries, quiz sessions) is automatically cleaned up.

## Story Data

Stories are loaded from a JSON file containing:
- Story metadata (title, feeling, animal character)
- Story text
- Multiple choice questions
- Explanations for each choice
- Age-appropriate content for different ranges

## Architecture Notes

- **Views**: SwiftUI views are kept simple and focused on presentation
- **Managers**: Business logic and data operations are handled in Manager classes
- **Models**: Data structures are organized in model files
- **State Management**: Uses `@State`, `@StateObject`, and `@ObservedObject` for SwiftUI state
- **Navigation**: Uses `NavigationStack` for navigation flow

## Privacy & Security

- **No data collection**: The app does not collect or transmit any personal information
- **Local storage only**: All data remains on the device
- **COPPA compliant**: Designed for children with privacy in mind
- **No third-party services**: No analytics, advertising, or tracking

## Contributing

When contributing to this project:

1. Follow the existing code structure and patterns
2. Ensure all data is properly cleaned up when children are deleted
3. Test on iOS 17.0+ devices/simulators
4. Maintain privacy-first approach (no external data transmission)
5. Keep UI accessible and child-friendly

## Troubleshooting

### Build Issues

- **"No such module" errors**: Clean build folder (`Cmd + Shift + K`) and rebuild
- **Signing errors**: Verify your Apple Developer account is configured correctly
- **Deployment target errors**: Ensure iOS 17.0 is set in project settings

### Runtime Issues

- **Data not persisting**: Check that UserDefaults keys are consistent
- **Stories not loading**: Verify story data file is included in the app bundle
- **Achievements not unlocking**: Check achievement manager logic and data persistence

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)
- [App Store Release Checklist](./APP_STORE_RELEASE_CHECKLIST.md)

## License

Copyright © 2025 Christopher Law. All rights reserved.

## Support

For issues or questions, please refer to the App Store Release Checklist or contact the development team.
