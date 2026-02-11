//
//  YoutubePlayerView.swift
//  MoviesApp
//
//  Created by Shivya Aggarwal on 11/02/26.
//

import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoKey: String
    var autoplay: Bool = false
    var muted: Bool = true    // if autoplay, keep muted = true for iOS
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        // Enables PiP & inline; not strictly required for simple playback:
        if #available(iOS 15.0, *) { config.mediaTypesRequiringUserActionForPlayback = [] }
        
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.isOpaque = false
        webview.backgroundColor = .clear
        webview.scrollView.isScrollEnabled = false
        return webview
    }

    func updateUIView(_ webview: WKWebView, context: Context) {
        guard !videoKey.isEmpty else {
            webview.loadHTMLString("", baseURL: nil)
            return
        }
        
        // Build embed URL
        var params = ["playsinline=1", "modestbranding=1", "rel=0"]
        if autoplay { params.append("autoplay=1") }
        if muted { params.append("mute=1") }
        let query = params.joined(separator: "&")
        let urlString = "https://www.youtube.com/embed/\(videoKey)?\(query)"
        
        if let current = webview.url?.absoluteString, current == urlString {
            // No need to reload if same
            return
        }
        
        if let url = URL(string: urlString) {
            DispatchQueue.main.async {
                webview.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30))
            }
        }
    }
}


#Preview {
    YouTubePlayerView(videoKey: "dQw4w9WgXcQ", autoplay: false, muted: true)
        .frame(height: 220)
        .padding()
}


