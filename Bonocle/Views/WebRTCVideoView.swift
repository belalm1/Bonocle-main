//
//  WebRTCVideoView.swift
//  Bonocle
//
//  Created by IS Student on 11/03/2023.
//

import SwiftUI
import WebRTC

struct WebRTCVideoView: UIViewRepresentable {
    let isLocalVideo: Bool
    let webRTCClient: WebRTCClient

    func makeUIView(context: Context) -> RTCMTLVideoView {
        let videoView = RTCMTLVideoView(frame: .zero)
        videoView.videoContentMode = .scaleAspectFill
        if isLocalVideo {
            webRTCClient.startCaptureLocalVideo(renderer: videoView)
        } else {
            webRTCClient.renderRemoteVideo(to: videoView)
        }
        return videoView
    }

    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        // Nothing to update
    }
}
