//
//  searchPhotos.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/31/21.
//

import Foundation

struct searchPhotos: Codable {
    let page: Int
    let pages: Int
    let perpage: String
    let total: String
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perpage
        case total
    }
}
