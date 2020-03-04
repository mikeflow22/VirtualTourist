//
//  NetworkController.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/3/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation

class NetworkController {
    private let baseURL = URL(string: "https://www.flickr.com/services/rest/")!
    
    func fetchPhotosAtGeoLocation(lat: Double, lon: Double, completion: @escaping ([PhotoRepresentation]?, Error?) -> Void){
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        let urlQueryItems = [URLQueryItem(name: "method", value: "flickr.photos.search"),
                             URLQueryItem(name: "api_key", value: "9e346b12d7b496480897bdbaf3efc3f7"),
                             URLQueryItem(name: "lat", value: "\(lat)"),
                             URLQueryItem(name: "lon", value: "\(lon)"),
                             URLQueryItem(name: "format", value: "json"),
                             URLQueryItem(name: "nojsoncallback", value: "1")
        ]
        
        urlComponents.queryItems = urlQueryItems
        let finalURL = urlComponents.url!
        
        URLSession.shared.dataTask(with: finalURL) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("Response: \(response.statusCode)")
            }
            
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
              completion(nil, error)
                return
            }

            print("Data returned: \(String(data: data, encoding: .utf8)!)")
            let decoder = JSONDecoder()
            
            do {
                let dictionary = try decoder.decode(TopLevelDictionary.self, from: data)
                let photos = dictionary.photos
                let photoRepresnetation = photos.photo
                
                for id in photoRepresnetation {
                    print("photoId: \(id.id)")
                }
               
                completion(photoRepresnetation, nil)
            } catch  {
                print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n line: \(#line)")
                completion(nil, error)
            }
        }.resume()
    }
}
