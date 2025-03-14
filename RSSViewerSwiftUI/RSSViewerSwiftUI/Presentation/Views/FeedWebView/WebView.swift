//
//  WebView.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 18.02.2025..
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
        // Use Binding instead of direct reference to isLoading
    @Binding var isLoading: Bool
    var url: URL?

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = context.coordinator
        if let url = url {
            webview.load(URLRequest(url: url))
        }
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
            // Can update the webview if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
                // Dispatch to main thread to update SwiftUI state
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }
}
