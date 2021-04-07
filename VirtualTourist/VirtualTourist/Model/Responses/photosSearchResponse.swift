//
//  photosSearchResponse.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/31/21.
//

import Foundation
    
struct photosSearchResponse: Codable {
    let photos: searchPhotos
    let stat: String
        
    enum CodingKeys: String, CodingKey {
        case photos
        case stat
    }
}

