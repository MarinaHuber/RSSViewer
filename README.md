
# RSSViewer

TL;DR  
Lightweight iOS RSS/Atom reader built with SwiftUI and MVVM. Add feeds, view items, and open full articles in a WebView. Includes unit and UI tests. Targets iOS 18 / Xcode 16.

## Quickstart (run in <10 minutes)
Prerequisites
- Xcode 16 or later
- macOS compatible with Xcode 16+
- Swift 5+

Get the code
git clone https://github.com/MarinaHuber/RSSViewer.git
cd RSSViewer

Open & run
1. Open `RSSViewer.xcodeproj` (or `.xcworkspace` if CocoaPods/Carthage used) in Xcode 16.
2. Select an iOS 18+ simulator (e.g., iPhone 16+).
3. Build (⌘B) and Run (⌘R).

Run tests
- Unit tests: Product → Test or `⌘U`
- UI tests: select the UI test target and run

## What it does ✅
- Add / remove RSS feeds by URL
- List feeds with title, image (when available), and description
- Open a feed to view items (item includes image, title, description)
- Open items in an embedded WebView or external browser

## Architecture (MVVM)
- **Model**: data structures for feeds & items  
- **ViewModel**: business logic, state management, Combine publishers  
- **View**: SwiftUI views and NavigationPath routing  
MVVM separates UI from business logic for testability and maintainability [[2]] [[4]].

Diagrams & flow
See `docs/architecture.md` and `diagrams/architecture.svg` for a component diagram (UI → ViewModel → Fetcher/Worker → Persistence).

## Tech stack / frameworks
- SwiftUI, Combine  
- URLSession for network fetches  
- XML parsing for RSS/Atom  
- WebView for article viewing  
- UserDefaults for simple persistence (consider CoreData/Postgres for scale)  
- NavigationPath routing

## Testing
- Unit tests: ViewModel, Data Managers  
- UI tests: automated test for adding a feed and basic UI flows

## Known limitations / Roadmap
- Background App Refresh (fetching in background) — planned  
- Favorites, Local Notifications, Deep Linking — planned

  
# Evidence 🕵️‍♀️
## **Screenshots/Videos** 📱
![Simulator Screen Recording - iPhone 16 - 2025-02-20 at 09 11 35](https://github.com/user-attachments/assets/cfdc1f96-7e9b-4f1a-94cc-f43239d7bd39)



## Contributing
Contributions welcome. Please open a PR and run the test suite before submitting. See `CONTRIBUTING.md` for details.

## License
MIT — see `LICENSE` file for details.





