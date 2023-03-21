//
//  UserViewModel.swift
//  Bonocle
//
//  Created by IS Student on 19/02/2023.
//

import Foundation
import Combine

class UserViewModel: ObservableObject, Identifiable {

  private let userRepository = UserRepository()
  @Published var user: User
  private var cancellables: Set<AnyCancellable> = []
  var uid = ""

  init(user: User) {
    self.user = user
    $user
      .compactMap { $0.id }
      .assign(to: \.uid, on: self)
      .store(in: &cancellables)
  }
}
