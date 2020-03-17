//
//  NetworkController.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/3/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import UIKit

class NetworkController {
    static let shared = NetworkController()
    
    private let baseURL = URL(string: "https://www.flickr.com/services/rest/")!
    var photoImagesOfCurrentNetworkCall = [UIImage]() {
        didSet {
            //            print("photoImagesOfCurrentNetworkCall set: \(photoImagesOfCurrentNetworkCall.count)")
        }
    }
    
    func fetchPhotoInformationAtGeoLocation(lat: Double, lon: Double, page: Int? = 1, completion: @escaping ([PhotoInformation]?, Error?) -> Void){
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        let urlQueryItems = [URLQueryItem(name: "method", value: "flickr.photos.search"),
                             URLQueryItem(name: "api_key", value: "9e346b12d7b496480897bdbaf3efc3f7"),
                             URLQueryItem(name: "lat", value: "\(lat)"),
                             URLQueryItem(name: "lon", value: "\(lon)"),
                             URLQueryItem(name: "format", value: "json"),
                             URLQueryItem(name: "page", value: "\(String(describing: page))"),
                             URLQueryItem(name: "nojsoncallback", value: "1")
        ]
        
        urlComponents.queryItems = urlQueryItems
        let finalURL = urlComponents.url!
        print("this is the url for fetch photos: \(finalURL)")
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
            
            //            print("Data returned: \(String(data: data, encoding: .utf8)!)")
            let decoder = JSONDecoder()
            
            do {
                let dictionary = try decoder.decode(TopLevelDictionary.self, from: data)
                let photos = dictionary.photos
                let photoRepresnetation = photos.photo
                
                DispatchQueue.main.async {
                    completion(photoRepresnetation, nil)
                }
            } catch  {
                print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n line: \(#line)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func fetchPhotos(withPhotoInformation photoInfo: [PhotoInformation], completion: @escaping(Error?) -> Void){
        //loop through the photoInformation to construct the url for each specific photo
        for onePhoto in photoInfo {
            let url = URL(string: "https://farm\(onePhoto.farm).staticflickr.com/\(onePhoto.server)/\(onePhoto.id)_\(onePhoto.secret)_m")!.appendingPathExtension("jpg")
            //            print("this is the constructed url for the photo: \(url)")
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    //                    print("Response in \(#function): \(response.statusCode)")
                }
                
                if let error = error {
                    print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                    completion(error)
                    return
                }
                
                guard let data = data else {
                    print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                    completion(error)
                    return
                }
                
                guard let imageFromData = UIImage(data: data) else {
                    print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                    completion(error)
                    return
                }
                
                DispatchQueue.main.async {
                    self.photoImagesOfCurrentNetworkCall.append(imageFromData)
                    print("appending the photoImagesOfCurrentNetworkCall array : \(self.photoImagesOfCurrentNetworkCall.count)")
                    completion(nil)
                }
            }.resume()
        }
    }
}
