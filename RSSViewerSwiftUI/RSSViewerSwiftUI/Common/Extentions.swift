//
//  Extentions.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//
import Foundation

extension String {
    var isValidURL: Bool {
        guard let components = URLComponents(string: self) else { return false }
        return ["http", "https"].contains(components.scheme?.lowercased()) && components.host != nil
    }
}


