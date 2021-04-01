//
//  photosSearchResponse.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/31/21.
//

import Foundation
class photosSearchResponse {
    
    struct photosSearchResponse: Codable {
        let photos: searchPhotos
        let photo: [searchPhoto]
        
        
        enum CodingKeys: String, CodingKey {
            case photos
            case photo
        }
    }
}
