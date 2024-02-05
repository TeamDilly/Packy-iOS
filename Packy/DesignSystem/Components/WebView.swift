//
//  WebView.swift
//  Packy
//
//  Created by Mason Kim on 2/5/24.
//

import SwiftUI
import WebKit

struct WebView: View {
    let urlString: String

    @State private var isLoading = true

    var body: some View {
        ZStack {
            WebViewRepresentable(urlString: urlString, isLoading: $isLoading)
                .edgesIgnoringSafeArea(.all)
            if isLoading {
                // TODO: 커스텀 로딩 인디케이터 연결
                ProgressView()
            }
        }
    }
}

// MARK: - UIViewRepresentable

private struct WebViewRepresentable: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.navigationDelegate = context.coordinator

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension WebViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewRepresentable

        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            return .allow
        }
    }
}

#Preview {
    WebView(urlString: "https://naver.com")
}
