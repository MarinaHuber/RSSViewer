//
//  ErrorAlert.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 20.02.2025..
//

import SwiftUI
import Combine

class ErrorAlert: ObservableObject {
    @Published var showError = false
    @Published var message = ""

    func show(error: Error) {
        self.message = error.localizedDescription
        self.showError = true
    }
}

struct ErrorAlertViewModifier: ViewModifier {
    @ObservedObject var errorAlert: ErrorAlert

    func body(content: Content) -> some View {
        content
            .alert(isPresented: $errorAlert.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorAlert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}

extension View {
    func errorAlert(_ errorAlert: ErrorAlert) -> some View {
        self.modifier(ErrorAlertViewModifier(errorAlert: errorAlert))
    }
}
