//
//  FlickrApi.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/28/21.
//

import Foundation
import UIKit

class FlickrAPI {
    
    static let base = "https://www.flickr.com/services/rest/"
    static let trailer = "&format=json&nojsoncallback=1"
    
    let key = "5635d9d448af681d854123142d8acc7d"
    let secret = "7b0eca14ea31e4ed"
    
  
}


/*
 @discardableResult class func taskForGETRequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
             print(String(data: data!, encoding: .utf8))
                guard let data = data else {
                    DispatchQueue.main.async {
                     completion(nil, error)
                    }
                    return
                }
                let decoder = JSONDecoder()
                do {
                 let responseObject = try decoder.decode(ResponseType.self, from: data[0..<data.count])
                    DispatchQueue.main.async {
                      completion(responseObject, nil)
                    }
                } catch {
                    do {
                     let errorResponse = try decoder.decode(Flickrresponse.self, from: data)
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

       
 https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=5635d9d448af681d854123142d8acc7d&lat=37.7749&lon=122.4194&page=1&format=json&nojsoncallback=1
 
 class func searchPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "{https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=} \(key) "&lat=" \(latitude) "&lon=" \(latitude) "&page=" \(page) "&format=json&nojsoncallback=1"}"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil { // Handle error…
              completion(false,error)
          }
          else {
            print(String(data: data!, encoding: .utf8)!)
            DispatchQueue.main.async {
              completion(true, nil)
            }
          }
        }
        task.resume()
    }

 */
