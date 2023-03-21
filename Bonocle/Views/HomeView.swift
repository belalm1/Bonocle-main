//
//  ContentView.swift
//  Bonocle
//
//  Created by IS Student on 19/02/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage

let coloredNavAppearance = UINavigationBarAppearance()

struct HomeView: View {
    
    // Sets style of page
    init() {
        coloredNavAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredNavAppearance.configureWithTransparentBackground()
        coloredNavAppearance.backgroundColor = .lightGray
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(descriptor: UIFontDescriptor(name: "Verdana", size: 18).withSymbolicTraits(.traitBold)!, size: 18)]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }
    
    // Observed value containing user data and loggedOut status
    @ObservedObject var vm = MainPageViewModel()
    
    @State private var isPresented = false
    @State var shouldShowLogOutOptions = false
    @State private var isRoomViewActive = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome, \(vm.user?.fname ?? "")")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button("Join Room") {
                    JoinRoomViewModelManager.shared.shouldInit = true
                    isRoomViewActive = true
                }
                .font(.system(size: 30, weight: .bold))
                .padding(.vertical, 80)
                .navigationDestination(isPresented: $isRoomViewActive) {
                    RoomView(
                        webRTCClient: JoinRoomViewModelManager.shared.webRTCClient,
                        joinViewModel: JoinRoomViewModelManager.shared.joinViewModel
                    )
                }
                .navigationBarTitle(Text("\(vm.user?.fname ?? "")'s Bonocle").font(.custom(
                    "Verdana", size: 12)))
                
                .navigationBarTitleDisplayMode(.inline)
                
                .font(.custom(
                    "Verdana",
                    fixedSize: 12))
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            shouldShowLogOutOptions.toggle()
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(.white))
                        }
                    }
                }
                
                .actionSheet(isPresented: $shouldShowLogOutOptions) {
                    .init(title: Text("Settings"), message: Text("Are you sure you want to sign out?"),
                          buttons: [.destructive(Text("Sign Out"), action: {
                        print("handle sign out")
                        vm.handleSignOut()
                    }),
                                    .cancel()
                                   ])
                }
                
                .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                    LoginView(didCompleteLogin: {
                        self.vm.isUserCurrentlyLoggedOut = false
                        self.vm.fetchCurrentUser()
                        
                    })
                }
            }
        }
    }
}
