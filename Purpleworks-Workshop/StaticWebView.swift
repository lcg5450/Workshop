//
//  StaticWebView.swift
//  Purpleworks-Workshop
//
//  Created by gomgom on 9/10/25.
//

import SwiftUI
@preconcurrency import WebKit

struct LocalHTMLView: UIViewRepresentable {
    let resource: String
    let ext: String

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator     // ✅ alert/prompt/confirm 처리
        return webView
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
    
    final class Coordinator: NSObject, WKUIDelegate {
        // alert
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            presentAlert(message: message, actions: ["확인"]) { _ in completionHandler() }
        }
        // confirm
        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            presentAlert(message: message, actions: ["취소","확인"]) { idx in completionHandler(idx == 1) }
        }
        // prompt
        func webView(_ webView: WKWebView,
                     runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            let ac = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            ac.addTextField { $0.text = defaultText }
            ac.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in completionHandler(nil) })
            ac.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                completionHandler(ac.textFields?.first?.text)
            })
            topVC()?.present(ac, animated: true)
        }

        private func presentAlert(message: String, actions: [String], tapped: @escaping (Int)->Void) {
            let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            for (i, t) in actions.enumerated() {
                let style: UIAlertAction.Style = (t == "취소") ? .cancel : .default
                ac.addAction(UIAlertAction(title: t, style: style) { _ in tapped(i) })
            }
            topVC()?.present(ac, animated: true)
        }

        private func topVC(base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController) -> UIViewController? {
            if let nav = base as? UINavigationController { return topVC(base: nav.visibleViewController) }
            if let tab = base as? UITabBarController { return topVC(base: tab.selectedViewController) }
            if let presented = base?.presentedViewController { return topVC(base: presented) }
            return base
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
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        if let url = Bundle.main.url(forResource: resource, withExtension: ext) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: resource, withExtension: ext) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    final class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
        let onMessage: (Any) -> Void
        let messageName: String
        let autoPasteOnAppear: Bool = true
        private var didAutoPasteOnce = false

        init(onMessage: @escaping (Any) -> Void, messageName: String) {
            self.onMessage = onMessage
            self.messageName = messageName
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == messageName else { return }
            onMessage(message.body)
        }
        
        // alert(...)
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            presentAlert(title: nil, message: message, actions: ["확인"]) { _ in
                completionHandler()
            }
        }

        // confirm(...)
        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            presentAlert(title: nil, message: message, actions: ["취소", "확인"]) { index in
                completionHandler(index == 1)
            }
        }

        // prompt(...)
        func webView(_ webView: WKWebView,
                     runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            let ac = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            ac.addTextField { $0.text = defaultText }
            ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in completionHandler(nil) }))
            ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                completionHandler(ac.textFields?.first?.text)
            }))
            topViewController()?.present(ac, animated: true)
        }

        // 공통 프리젠트
        private func presentAlert(title: String?, message: String?, actions: [String],
                                  tapped: @escaping (Int) -> Void) {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for (i, title) in actions.enumerated() {
                let style: UIAlertAction.Style = (title == "취소") ? .cancel : .default
                ac.addAction(UIAlertAction(title: title, style: style, handler: { _ in tapped(i) }))
            }
            topViewController()?.present(ac, animated: true)
        }

        // 최상단 VC 찾기
        private func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController) -> UIViewController? {
            if let nav = base as? UINavigationController { return topViewController(base: nav.visibleViewController) }
            if let tab = base as? UITabBarController { return topViewController(base: tab.selectedViewController) }
            if let presented = base?.presentedViewController { return topViewController(base: presented) }
            return base
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard autoPasteOnAppear, !didAutoPasteOnce else { return }
            didAutoPasteOnce = true

            // iOS 클립보드에서 문자열 읽기
            guard let text = UIPasteboard.general.string, !text.isEmpty else { return }

            // JS 문자열 리터럴로 안전하게 이스케이프
            let escaped = Self.jsStringLiteral(from: text)

            // 페이지에 정의된 window.__autoPaste 호출
            let js = "window.__autoPaste && window.__autoPaste(\(escaped));"
            webView.evaluateJavaScript(js) { _, err in
                if let err { print("autoPaste JS error:", err) }
            }
        }

        // JS 문자열 리터럴 생성기: "..." 형태로 안전하게 감싸줌
        static func jsStringLiteral(from s: String) -> String {
            // ["text"] 형태의 JSON을 만들고 대괄호 제거 → 안전한 JS 문자열 리터럴
            if let data = try? JSONSerialization.data(withJSONObject: [s], options: []),
               var str = String(data: data, encoding: .utf8) {
                str.removeFirst() // [
                str.removeLast()  // ]
                return str        // "..." 형태
            }
            // fallback
            let escaped = s.replacingOccurrences(of: "\\", with: "\\\\")
                           .replacingOccurrences(of: "\"", with: "\\\"")
                           .replacingOccurrences(of: "\n", with: "\\n")
                           .replacingOccurrences(of: "\r", with: "\\r")
            return "\"\(escaped)\""
        }
    }
}
