//
//  flickrErrorResponse.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/31/21.
//

import Foundation

struct flickrErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case stat
        case code
        case message
    }
}

extension flickrErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
