//
//  JoinRoomViewModel.swift
//  Bonocle
//
//  Created by IS Student on 10/03/2023.
//

import Foundation
import WebRTC

class JoinRoomViewModelManager {
    static let shared = JoinRoomViewModelManager(mainPageViewModel: nil)
    var shouldInit = false {
        didSet {
            if shouldInit {
                webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
                joinViewModel = JoinRoomViewModel(webRTCClient: webRTCClient, mainPageViewModel: mainPageViewModel!)
            }
        }
    }
    var webRTCClient: WebRTCClient!
    var joinViewModel: JoinRoomViewModel?
    var mainPageViewModel: MainPageViewModel?
    
    private init(mainPageViewModel: MainPageViewModel?) {
        self.mainPageViewModel = mainPageViewModel
    }
    
    static func initialize(mainPageViewModel: MainPageViewModel) {
        shared.mainPageViewModel = mainPageViewModel
        shared.shouldInit = true
    }

    func destroyJoinRoomModel() {
        self.joinViewModel = nil
        //self.webRTCClient.peerConnection.close()
        self.webRTCClient = nil
        self.shouldInit = false
        print("Should Init = false")
    }
}

class JoinRoomViewModel: ObservableObject {
    
    lazy var signalClient: SignalingClient = self.buildSignalingClient()
    private let webRTCClient: WebRTCClient
    private let mainPageViewModel: MainPageViewModel
    private let config = Config.default
    private var connectionCount: String
    private var waitingForOffer = true
    
    @Published var signalingConnected = false
    @Published var hasLocalSdp = false
    @Published var hasRemoteSdp = false
    @Published var connectionState: RTCIceConnectionState
    @Published var showVideo = false
    @Published var role = ""
    @Published var displayName : String = ""

    var localCandidateCount = 0
    var remoteCandidateCount = 0
    @Published var messages: [ChatMessage] = []
    
    private func buildSignalingClient() -> SignalingClient {
        let webSocketProvider = NativeWebSocket(url: self.config.signalingServerUrl)
        return SignalingClient(webSocket: webSocketProvider)
    }
    
    init(webRTCClient: WebRTCClient, mainPageViewModel: MainPageViewModel) {
        self.connectionCount = "0"
        self.connectionState = RTCIceConnectionState.new
        self.webRTCClient = webRTCClient
        self.mainPageViewModel = mainPageViewModel
        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        self.signalClient.connect()
        self.role = mainPageViewModel.user?.role ?? "None"

        // displayName is the first name and the first letter of the last name
        self.displayName = (self.role) + " " + (mainPageViewModel.user?.fname ?? "")
        print("Connecting")
    }

    // Function to end the call
    func endCall() {
        self.webRTCClient.peerConnection.close()
        //self.signalClient.disconnect()
        print("Ended Call")
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
        if self.role == "Student" && self.waitingForOffer{
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
        if Int(connectionCount)! == 2 {
            if self.role == "Teacher" {
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
    // Function to receive data from the other user
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            // Receive data
            let messageDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            let message = messageDict?["message"] ?? ""
            let displayName = messageDict?["displayName"] ?? ""

            //let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"

            // Add message to array with the displayName and the timestamp formatted in HH:mm
            self.messages.append(ChatMessage(timestamp: Date(), isMe: false, message: message, displayName: displayName))
            print(message)
        }
    }

    // Function to send data to the other user
    func sendMessage(message: String, displayName: String) {
        let messageDict = ["message": message, "displayName": displayName]
        // Convert to JSON
        let jsonData = try? JSONSerialization.data(withJSONObject: messageDict)
        // Send data
        self.webRTCClient.sendData(jsonData!)
        self.messages.append(ChatMessage(timestamp: Date(), isMe: true, message: message, displayName: displayName))
    }
}

