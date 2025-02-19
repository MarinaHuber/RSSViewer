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


    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: RSSFeedsViewModel(), router: Router())
                .environmentObject(router)
        }
    }
}
