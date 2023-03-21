//
//  Message.swift
//  WebRTC-Demo
//
//  Created by Stasel on 20/02/2019.
//  Copyright © 2019 Stasel. All rights reserved.
//

import Foundation

enum Message {
    case sdp(SessionDescription)
    case candidate(IceCandidate)
    case connectionCount(String)
}

extension Message: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case String(describing: SessionDescription.self):
            self = .sdp(try container.decode(SessionDescription.self, forKey: .payload))
        case String(describing: IceCandidate.self):
            self = .candidate(try container.decode(IceCandidate.self, forKey: .payload))
        case String(describing: String.self):
            self = .connectionCount(try container.decode(String.self, forKey: .payload))
            print(self)
        default:
            print("Container: ")
            print(container)
            print("Type: " + type)
            throw DecodeError.unknownType
        }
    }

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sdp(let sessionDescription):
            try container.encode(sessionDescription, forKey: .payload)
            try container.encode(String(describing: SessionDescription.self), forKey: .type)
        case .candidate(let iceCandidate):
            try container.encode(iceCandidate, forKey: .payload)
            try container.encode(String(describing: IceCandidate.self), forKey: .type)
        case .connectionCount(_):
            // Nothing, we never need to send a number of connection, only receive
            return
        }
    }
    
    enum DecodeError: Error {
        case unknownType
    }
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
}
