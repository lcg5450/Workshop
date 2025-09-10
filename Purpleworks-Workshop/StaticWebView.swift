//
//  StaticWebView.swift
//  Purpleworks-Workshop
//
//  Created by gomgom on 9/10/25.
//

import SwiftUI
import WebKit

struct LocalHTMLView: UIViewRepresentable {
    let resource: String
    let ext: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: resource, withExtension: ext) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let html = """
            <html><head><meta name="viewport" content="width=device-width, initial-scale=1">
            <style>body{font-family:-apple-system;margin:2rem;}</style></head>
            <body><h2>정적 페이지가 없습니다</h2><p>Bundle에 \(resource).\(ext)을 추가하세요.</p></body></html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}

struct WebScoreboardView: View {
    var body: some View {
        LocalHTMLView(resource: "scoreboard", ext: "html")
            .navigationTitle("점수 보드")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocalHTMLBridgeView: UIViewRepresentable {
    let resource: String
    let ext: String
    let messageName: String          // 예: "teamSync"
    var onMessage: (Any) -> Void     // JS에서 postMessage로 보낸 payload

    func makeCoordinator() -> Coordinator {
        Coordinator(onMessage: onMessage, messageName: messageName)
    }

    func makeUIView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: messageName)

        let config = WKWebViewConfiguration()
        config.userContentController = controller

        return WKWebView(frame: .zero, configuration: config)
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: resource, withExtension: ext) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    final class Coordinator: NSObject, WKScriptMessageHandler {
        let onMessage: (Any) -> Void
        let messageName: String

        init(onMessage: @escaping (Any) -> Void, messageName: String) {
            self.onMessage = onMessage
            self.messageName = messageName
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == messageName else { return }
            onMessage(message.body)
        }
    }
}
