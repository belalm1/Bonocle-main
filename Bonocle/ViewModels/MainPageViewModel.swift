//
//  MainPageViewModel.swift
//  Bonocle
//
//  Created by IS Student on 19/02/2023.
//

import Foundation
import Firebase
import FirebaseStorage

class MainPageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var user: User?
    
    init() {
        print("MAINPAGEVIEWMODEL-----------")
        DispatchQueue.main.async {
            // Checks if the current user is logged out (aka, has a uid)
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        // If the user is not logged in, end this function now and throw an error message
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        
        // Get the user and their values, and put them in the self.user variable
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument {
            
            // Check if there's an error, and stop the code if one is found
            snapshot, error in if let error = error {
                print("Failed to fetch current user", error)
                return
            }
            
            // Retreive data from snapshot
            guard let data = snapshot?.data() else { return }
            print(data)

            // Retreive each value from the data
            let uid = data["uid"] as? String ?? ""
            let fname = data["fname"] as? String ?? ""
            let lname = data["lname"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let role = data["role"] as? String ?? ""

            print(role)
            
            // Set the self.user to a new User instance with all the values from the data
            self.user = User(id: uid, fname: fname, lname: lname, email: email, role: role)
            
        }
    }
    
    // Set to false, since we are now logged in
    @Published var isUserCurrentlyLoggedOut = false
    
    // Clean the appropriate variables if signing out
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
    
}
