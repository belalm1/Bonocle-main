//
//  JoinRoomView.swift
//  Bonocle
//
//  Created by IS Student on 10/03/2023.
//

import SwiftUI
import WebRTC

struct RoomView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isSpeakerOn = false
    @State private var isMicOn = true
    @State private var isCamOn = true
    @State private var rtcStatReport: RTCStatisticsReport?
    @State private var stats: [String: RTCStatistics]?
    @State private var isMenuCollapsed = true
    @State var showChatView = false
    
    let parentView: HomeView
    
    private let buttonWidth: CGFloat = 40
    private let buttonPadding: CGFloat = 10
    
    @ObservedObject var joinViewModel: JoinRoomViewModel
    let webRTCClient: WebRTCClient
    
    private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(parentView: HomeView){
        self.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        self.webRTCClient = JoinRoomViewModelManager.shared.webRTCClient!
        self.joinViewModel = JoinRoomViewModelManager.shared.joinViewModel!
        self.parentView = parentView
    }
    
    var body: some View {
        if self.joinViewModel.connectionState == .new {
            VStack(spacing: 20) {
                Spacer()
                Text("Waiting for participants...")
                ProgressView()
                Button(action: {
                    //webRTCClient.peerConnection.close()
                    parentView.showRoomView = false
                    JoinRoomViewModelManager.shared.destroyJoinRoomModel()
                    joinViewModel.signalClient.disconnect()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Leave")
                        .font(.title)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .edgesIgnoringSafeArea(.all)
        } else if self.joinViewModel.connectionState == .disconnected {
            VStack(spacing: 20) {
                Spacer()
                Text("Lost Connection, attempting to reconnect...")
                ProgressView()
                Button(action: {
                    //webRTCClient.peerConnection.close()
                    parentView.showRoomView = false
                    JoinRoomViewModelManager.shared.destroyJoinRoomModel()
                    joinViewModel.signalClient.disconnect()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Leave")
                        .font(.title)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .edgesIgnoringSafeArea(.all)
        } else if self.joinViewModel.connectionState == .failed {
            VStack(spacing: 20) {
                Spacer()
                Text("Connection has failed")
                Button(action: {
                    //webRTCClient.peerConnection.close()
                    parentView.showRoomView = false
                    JoinRoomViewModelManager.shared.destroyJoinRoomModel()
                    joinViewModel.signalClient.disconnect()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Leave")
                        .font(.title)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .edgesIgnoringSafeArea(.all)
        } else if self.joinViewModel.connectionState == .connected {
            ZStack{
                WebRTCVideoView(isLocalVideo: false, webRTCClient: webRTCClient)
                    .background(Color.brown)
                    .frame(maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.vertical)
                ZStack {
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 60)
                            .foregroundColor(.white)
                            .background(.ultraThinMaterial)
                            .cornerRadius(90)
                            .padding(.horizontal)
                    }.frame(maxHeight: .infinity, alignment: .bottom)
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
                                .resizable()
                                .frame(width: buttonWidth, height: buttonWidth)
                                .foregroundColor(isSpeakerOn ? .red : .gray)
                                .padding(.bottom, buttonPadding)
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
                                .resizable()
                                .frame(width: buttonWidth, height: buttonWidth)
                                .foregroundColor(isMicOn ? .red : .gray)
                                .padding(.bottom, buttonPadding)
                        }
                        Button(action: {
                            isCamOn.toggle()
                            if isCamOn {
                                webRTCClient.showVideo()
                            } else {
                                webRTCClient.hideVideo()
                            }
                        }) {
                            Image(systemName: "video.circle.fill")
                                .resizable()
                                .frame(width: buttonWidth, height: buttonWidth)
                                .foregroundColor(isCamOn ? .red : .gray)
                                .padding(.bottom, buttonPadding)
                        }
                        Button(action: {
                            showChatView = true
                        }) {
                            Image(systemName: "bubble.left.circle.fill")
                                .resizable()
                                .frame(width: buttonWidth, height: buttonWidth)
                                .foregroundColor(.red)
                                .padding(.bottom, buttonPadding)
                        }
                        // End meeting button
                        Button(action: {
                            parentView.showRoomView = false
                            JoinRoomViewModelManager.shared.destroyJoinRoomModel()
                            joinViewModel.signalClient.disconnect()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "phone.down.circle.fill")
                                .resizable()
                                .frame(width: buttonWidth, height: buttonWidth)
                                .foregroundColor(.red)
                                .padding(.bottom, buttonPadding)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                
                WebRTCVideoView(isLocalVideo: true, webRTCClient: webRTCClient)
                    .frame(width: 120, height: 160)
                    .background(.clear)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .onReceive(timer) { _ in
                Task {
                    await StatsToJSON(webrtc: self.webRTCClient)
                }
            }
            .onChange(of: webRTCClient.rtcAudioSession.isActive){ _ in
                print("SPEAKER CHANGED")
                webRTCClient.speakerOn()
                isSpeakerOn = true
            }
            .fullScreenCover(isPresented: $showChatView, onDismiss: nil) {
                ChatView(parentView: self)
            }
        }
    }
}
