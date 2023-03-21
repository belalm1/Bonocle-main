//
//  UserRepository.swift
//  Bonocle
//
//  Created by IS Student on 19/02/2023.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserRepository: ObservableObject, Identifiable {

    private let path: String = "users"
    private let store = Firestore.firestore()

      @Published var users: [User] = []
      private var cancellables: Set<AnyCancellable> = []

      init() {
        self.get()
      }

      func get() {
        store.collection(path).addSnapshotListener { querySnapshot, error in
            if let error = error {
              print("Error getting books: \(error.localizedDescription)")
              return
            }

            self.users = querySnapshot?.documents.compactMap { document in
              try? document.data(as: User.self)
            } ?? []
          }
      }
    
    func add(_ user: User) {
        do {
          let newUser = user
          _ = try store.collection(path).addDocument(from: newUser)
        } catch {
          fatalError("Unable to add user: \(error.localizedDescription).")
        }
      }
}
