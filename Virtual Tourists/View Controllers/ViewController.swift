//
//  ViewController.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/3/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        test { (success, error) in
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                return
            }
            
            if success {
                print("Success in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                DispatchQueue.main.async {

                }
            } else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return
            }
        }
    }


    func test(completion: @escaping (Bool, Error?) -> Void){
        
        let baseURL = URL(string: "https://www.flickr.com/services/rest/")!
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        let urlQueryItems = [URLQueryItem(name: "method", value: "flickr.photos.search"),
                             URLQueryItem(name: "api_key", value: "9e346b12d7b496480897bdbaf3efc3f7"),
                             URLQueryItem(name: "lat", value: "36.1699"),
                             URLQueryItem(name: "lon", value: "115.1398"),
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
                completion(false, error)
                return
            }
            
            guard let data = data else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
              completion(false, error)
                return
            }

            print("Data returned: \(String(data: data, encoding: .utf8)!)")
            let decoder = JSONDecoder()
            
            do {
                let dictionary = try decoder.decode(TopLevelDictionary.self, from: data)
                let photos = dictionary.photos
                let photo = photos.photo
                for id in photo {
                    print("photoId: \(id.id)")
                }
               
                completion(true, nil)
            } catch  {
                print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n line: \(#line)")
                
                completion(false, error)
                
            }
        }.resume()
    }
}

