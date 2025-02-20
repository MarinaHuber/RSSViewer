//
//  AppState.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var checkForNewItems = false
    @Published var navigateToFeedPath = ""

    private init() {}
}
