//
//  RSSViewerSwiftUIApp.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 14.02.2025..
//

import SwiftUI

@main
struct RSSViewerSwiftUIApp: App {
    @StateObject private var router = Router<Route>()
    @StateObject private var errorAlert = ErrorAlert()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: RSSFeedsViewModel(), router: Router())
                .environmentObject(router)
                .environmentObject(AppState.shared)
                .environmentObject(errorAlert)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    try? BRefreshService.scheduleTask()
                }
        }
    }
}

// TODO: - ADD LOCAL NOTIFICATION FOR BG MODE
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BRefreshService.register(callback: checkForNewItems)
        return true
    }

    private func checkForNewItems() {
        DispatchQueue.main.async {
            AppState.shared.checkForNewItems = true
        }
    }
}

