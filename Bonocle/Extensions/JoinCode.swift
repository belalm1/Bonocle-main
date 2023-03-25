//
//  JoinCode.swift
//  Bonocle
//
//  Created by IS Student on 22/03/2023.
//

import Foundation

struct JoinCode: Codable {
    var code: String
    
    init(from joinCode: String) {
        self.code = joinCode
    }
    
    var joinCode: String {
        return code
    }
}
