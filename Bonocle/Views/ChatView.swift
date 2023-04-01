//
//  ChatView.swift
//  Bonocle
//
//  Created by IS Student on 31/03/2023.
//

import SwiftUI

class ChatMessage {
    var timestamp: Date
    var isMe: Bool
    var message: String
    var displayName: String
    
    init(timestamp: Date, isMe: Bool, message: String, displayName: String) {
        self.timestamp = timestamp
        self.isMe = isMe
        self.message = message
        self.displayName = displayName
    }
}

struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: JoinRoomViewModel
    @State var messageText: String = ""
    let dateFormatter = DateFormatter()
    let parentView: RoomView
    
    init(parentView: RoomView) {
        self.viewModel = JoinRoomViewModelManager.shared.joinViewModel!
        self.parentView = parentView
        self.dateFormatter.dateFormat = "hh:mm a"
    }
    
    var body: some View {
//        if self.viewModel.connectionState != .connected {
//            // Dismiss the current view
//            self.parentView.showChatView = false
//            let _ = presentationMode.wrappedValue.dismiss()
//        } else {
            // VStack to display the chat and text entry field
        VStack {
            // List to display the messages
            List {
                // Loop through the messages
                ForEach(viewModel.messages , id: \.timestamp) { message in
                    // Display the message
                    HStack {
                        // If the message is from the user, display it on the right
                        if message.isMe {
                            Spacer()
                            VStack {
                                // Caption with the displayName and time, aligned to the right
                                Text(self.dateFormatter.string(from: message.timestamp) + ", " + message.displayName)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)

                                // Add the message
                                Text(message.message)
                                    // Add horizontal padding
                                    .padding(.horizontal, 10)
                                    // Add vertical padding
                                    .padding(.vertical, 5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        // If the message is from the other user, display it on the left
                        else {
                            VStack {
                                // Caption with the displayName and timestamp aligned to the left
                                Text(self.dateFormatter.string(from: message.timestamp) + ", " + message.displayName)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Add the message
                                Text(message.message)
                                    // Add horizontal padding
                                    .padding(.horizontal, 10)
                                    // Add vertical padding
                                    .padding(.vertical, 7)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer()
                        }
                    }.listRowBackground(Color.clear)
                }
            }
            // Text field and "send" button
            HStack {
                // Text field to enter the message
                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                // "Send" button to add the message to the list
                Button("Send") {
                    // Check if the message is empty
                    if messageText == "" {
                        // If it is, return
                        return
                    }
                    
                    // Send the message to the server
                    viewModel.sendMessage(message: messageText, displayName: viewModel.displayName)
                    
                    // Clear the text field
                    messageText = ""
                }
            }
            .padding()
        }
        // NavigationView to display the chat
        .navigationTitle("Chat")
        .onChange(of: self.viewModel.connectionState) { newValue in
            print("Ice connection state changed to \(newValue)")
            if newValue != .connected {
                self.parentView.showChatView = false
                presentationMode.wrappedValue.dismiss()
            }
        }
        //}
    }
}
