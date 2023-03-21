//
//  JoinRoomViewModel.swift
//  Bonocle
//
//  Created by IS Student on 10/03/2023.
//

import Foundation
import WebRTC

class JoinRoomViewModel: ObservableObject {
    
    private lazy var signalClient: SignalingClient = self.buildSignalingClient()
    private let webRTCClient: WebRTCClient
    private let config = Config.default
    private let isTeacher = false // Later should be replaced with value from FireStore
    private var connectionCount: String
    private var waitingForOffer = true
    
    @Published var signalingConnected = false
    @Published var hasLocalSdp = false
    @Published var hasRemoteSdp = false
    @Published var connectionState: RTCIceConnectionState
    @Published var showVideo = false
    var localCandidateCount = 0
    var remoteCandidateCount = 0
    
    private func buildSignalingClient() -> SignalingClient {
        let webSocketProvider = NativeWebSocket(url: self.config.signalingServerUrl)
        return SignalingClient(webSocket: webSocketProvider)
    }
    
    init(webRTCClient: WebRTCClient) {
        self.connectionCount = "0"
        self.connectionState = RTCIceConnectionState.new
        self.webRTCClient = webRTCClient
        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        self.signalClient.connect()
        print("Connecting")
    }
}

extension JoinRoomViewModel: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
        print("Signaling Connected")
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
        print("Signaling Disconnected")
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received Remote SDP")
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
        }
        if !self.isTeacher && self.waitingForOffer{
            // The current user is not the teacher and is waiting for an offer
            self.webRTCClient.answer { (localSdp) in
                self.hasLocalSdp = true
                self.signalClient.send(sdp: localSdp)
            }
            self.waitingForOffer = false
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient.set(remoteCandidate: candidate) { error in
            print("Received Remote Candidate")
            self.remoteCandidateCount += 1
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveConnectionCount connectionCount: String) {
        self.connectionCount = connectionCount
        if Int(connectionCount)! >= 2 {
            if self.isTeacher {
                // The current user is the teacher, so send an offer
                self.webRTCClient.offer { (sdp) in
                    self.hasLocalSdp = true
                    self.signalClient.send(sdp: sdp)
                }
            } else {
                // The current user is not the teacher, so wait for an offer
                //...
            }
        }
    }
}

extension JoinRoomViewModel: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        self.connectionState = state
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            print(message)
        }
    }
}

