//
//  RSSFeedNavigation.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 18.02.2025..
//

import Combine

class Router<Route: Hashable>: ObservableObject {
    @Published var currentRoute: [Route] = []

    func push(_ route: Route) {
        currentRoute.append(route)
    }

    func pop() {
        currentRoute.removeLast()
    }

    func goToRoot() {
        currentRoute.removeAll()
    }
}
