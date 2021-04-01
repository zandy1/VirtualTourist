//
//  searchPhoto.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/31/21.
//

import Foundation

struct searchPhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
    }
    
    func computeURL() -> String {
      return "https://live.staticflickr.com/" + server + "/" + id + "_" + secret + ".jpg"
    }
}
