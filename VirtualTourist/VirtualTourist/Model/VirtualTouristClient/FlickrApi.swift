//
//  FlickrApi.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/28/21.
//

import Foundation
import UIKit

class FlickrAPI {
    
    //static let base = "https://www.flickr.com/services/rest/"
    static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key="
    static let trailer = "&format=json&nojsoncallback=1"
    static let key = "5635d9d448af681d854123142d8acc7d"
    static let secret = "7b0eca14ea31e4ed"
    
    enum Endpoints {

        case searchPhotos(String,String,String)
    
        var stringValue: String {
        switch self {
        
        case .searchPhotos(let lat, let lon, let page): return base + key + "&lat=" + lat + "&lon=" + lon + "&page=" + page + trailer
        }
      }
    
      var url: URL {
        return URL(string: stringValue)!
      }
    }

/*
 https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=5635d9d448af681d854123142d8acc7d&lat=37.7749&lon=122.4194&page=1&format=json&nojsoncallback=1
 */
    
    @discardableResult class func taskForGETRequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
           let task = URLSession.shared.dataTask(with: url) { data, response, error in
               guard let data = data else {
                   DispatchQueue.main.async {
                    completion(nil, error)
                   }
                   return
               }
               let decoder = JSONDecoder()
               do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                   DispatchQueue.main.async {
                     completion(responseObject, nil)
                   }
               } catch {
                   do {
                    let errorResponse = try decoder.decode(flickrErrorResponse.self, from: data)
                       DispatchQueue.main.async() {
                        completion(nil, errorResponse)
                       }
                   }
                   catch {
                     DispatchQueue.main.async {
                       completion(nil, error)
                     }
                   }
               }
           }
           task.resume()
           return task
       }
    
 
    
 class func searchPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping (Bool, Error?) -> Void) {
   
    let url = Endpoints.searchPhotos(String(latitude), String(longitude), String(page)).url
    taskForGETRequest(url: url, response: photosSearchResponse.self) { (response, error) in
               if let response = response {
                VirtualTouristModel = response
                completion(true,nil)
               }
               else {
                completion(false,error)
               }
           }
}


}

