//
//  JoinRoomView.swift
//  Bonocle
//
//  Created by IS Student on 10/03/2023.
//

import SwiftUI
import WebRTC

class JoinRoomViewModelManager {
    static let shared = JoinRoomViewModelManager()
        var shouldInit = false {
            didSet {
                if shouldInit {
                    joinViewModel = JoinRoomViewModel(webRTCClient: webRTCClient)
                    webRTCClient.speakerOn()
                }
            }
        }
        var webRTCClient: WebRTCClient!
        var joinViewModel: JoinRoomViewModel?
        
        private init() {
            webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        }
}

struct RoomView: View {
    
    @State private var isSpeakerOn = false
    @State private var isMicOn = true
    @State private var isDebugOn = false
    @State private var isCamOn = true
    @State private var rtcStatReport: RTCStatisticsReport?
    @State private var stats: [String: RTCStatistics]?
    
    let webRTCClient: WebRTCClient
    let joinViewModel: JoinRoomViewModel?
    private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(webRTCClient: WebRTCClient, joinViewModel: JoinRoomViewModel?){
        self.webRTCClient = webRTCClient
        self.joinViewModel = joinViewModel
        self.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    }
    
    var body: some View {
        VStack {
            WebRTCVideoView(isLocalVideo: false, webRTCClient: webRTCClient)
                .scaledToFit()
                .frame(height: 400)
                .offset(y: -100)
            WebRTCVideoView(isLocalVideo: true, webRTCClient: webRTCClient)
                .scaledToFit()
                .frame(height: 200)
            if isDebugOn {
                //Text(stats.)
            }
            Spacer()
        }
        HStack {
            Button(action: {
                isSpeakerOn.toggle()
                if isSpeakerOn {
                    webRTCClient.speakerOn()
                } else {
                    webRTCClient.speakerOff()
                }
            }) {
                Image(systemName: isSpeakerOn ? "speaker.wave.2.circle.fill" : "phone.circle.fill")
                    .foregroundColor(isSpeakerOn ? .red : .gray)
                    .font(.title)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            
            Button(action: {
                isMicOn.toggle()
                if isMicOn {
                    webRTCClient.muteAudio()
                } else {
                    webRTCClient.unmuteAudio()
                }
            }) {
                Image(systemName: isMicOn ? "mic.circle.fill" : "mic.slash.circle.fill")
                    .foregroundColor(isMicOn ? .red : .gray)
                    .font(.title)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            Button(action: {
                isDebugOn.toggle()
            }) {
                Image(systemName: isDebugOn ? "hammer.circle.fill" : "hammer.circle")
                    .foregroundColor(isDebugOn ? .red : .gray)
                    .font(.title)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            Button(action: {
                isCamOn.toggle()
                if isCamOn {
                    webRTCClient.showVideo()
                } else {
                    webRTCClient.hideVideo()
                }
            }) {
                Image(systemName: isCamOn ? "camera.circle.fill" : "camera.circle")
                    .foregroundColor(isCamOn ? .red : .gray)
                    .font(.title)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
        }
        .onReceive(timer) { _ in
            Task {
                await StatsToJSON(webrtc: self.webRTCClient)
            }
        }
    }
}
