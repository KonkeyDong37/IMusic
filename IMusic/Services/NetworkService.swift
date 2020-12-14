//
//  NetworkService.swift
//  IMusic
//
//  Created by Андрей on 02.12.2020.
//

import UIKit
import Alamofire

class NetworkService {
    
    func fetchTracks(searchText: String, completion: @escaping (SearchResponseModel?) -> Void) {
        let url = "https://itunes.apple.com/search"
        let params: [String : Any] = [
            "term" : searchText,
            "limit" : 25,
            "media" : "music"
        ]
        
        AF.request(url, parameters: params).responseData { (response) in
            if let error = response.error {
                print("Error received requestion data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = response.data else { return }
            let decoder = JSONDecoder()
            
            do {
                let objects = try decoder.decode(SearchResponseModel.self, from: data)
                completion(objects)
            } catch let error {
                print("Failed to decode JSON: \(error)")
                completion(nil)
            }
        }
    }
}
