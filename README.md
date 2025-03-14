
# RSSViewer
## What was done? ✅
> - Architecture  

This project follows the Model-View-ViewModel (MVVM) pattern. The key components of the architecture include:

Model: Defines the data structures for items and any associated properties
ViewModel: Manages business logic and state, bridging data and the UI
View: SwiftUI views that display data from the ViewModel and handle user interaction
> - Frameworks  

XML Parser
URL Session (foreground),
WebView,
Combine,
UserDefaults Data Persistence,
Navigation Path Routing

> - Testing  

Unit Tests: Tests for ViewModel, Data Managers, 
UI Tests: Automated tests to check UI functionality of adding an RSS feed


# Description 📝
## Project Info 📈
> - Requirements

>   - 1.As a user, I can add RSS feed by specifying an RSS feed URL
>   - 2.As a user, I can remove RSS feeds
>   - 3.As a user, I can see added RSS feeds

Each RSS feed presentation should include RSS feed name, image (if it
exists), description

>   -4.As a user, I can select an RSS feed to open a screen with the RSS feed items
Each RSS feed item presentation should include an image (if it exists),
title, description

>   - 5.As a user, I can select an RSS item to access the related website/feed
The app can open an RSS item link in WebView or device browser.

Xcode 16 or later  

iOS 18 or later  

Swift 5 or later  
  
# Evidence 🕵️‍♀️
## **Screenshots/Videos** 📱
![Simulator Screen Recording - iPhone 16 - 2025-02-20 at 09 11 35](https://github.com/user-attachments/assets/cfdc1f96-7e9b-4f1a-94cc-f43239d7bd39)


**Additional context** 🌎
>   - Missing implementation for:

Background App Refresh Tasking,

Favourite RSS & local notifications (Deep Linking)





