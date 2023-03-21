//
//  UsersViewModel.swift
//  Bonocle
//
//  Created by IS Student on 19/02/2023.
//

import Foundation
import Combine

class UsersViewModel: ObservableObject {
  @Published var userViewModel: [UserViewModel] = []
  private var cancellables: Set<AnyCancellable> = []

  @Published var userRepository = UserRepository()
  @Published var library: [User] = []
  
  init() {
      userRepository.$users.map { users in
      users.map(UserViewModel.init)
    }
    .assign(to: \.userViewModel, on: self)
    .store(in: &cancellables)
  }

  func add(_ user: User) {
      userRepository.add(user)
  }
}
