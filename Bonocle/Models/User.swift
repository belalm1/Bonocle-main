//
//  User.swift
//  Bonocle
//
//  Created by IS Student on 19/02/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var fname: String
    var lname: String
    var email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fname
        case lname
        case email
    }
        

}
