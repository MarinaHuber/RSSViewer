//
//  UserDefaultWrapper.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 19.02.2025..
//

import Foundation

//UserDefaults can be observed using Key-Value Observing for any key stored in it.
@propertyWrapper
struct UserDefaultsWrapper<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults

    init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key),
                  let value = try? JSONDecoder().decode(T.self, from: data) else {
                return defaultValue
            }
            return value
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.setValue(data, forKey: key)
            }
        }
    }
}
