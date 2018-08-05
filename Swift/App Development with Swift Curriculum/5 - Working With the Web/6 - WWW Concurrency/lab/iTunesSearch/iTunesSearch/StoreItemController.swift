//
//  StoreItemController.swift
//  iTunesSearch
//
//  Created by Tyler Gee on 7/27/18.
//  Copyright © 2018 Caleb Hicks. All rights reserved.
//

import Foundation

class StoreItemController {
    func fetchItems(matching query: [String: String], completion: @escaping ([StoreItem]?) -> Void) {
        
        let baseURL = URL(string: "https://itunes.apple.com/search?")!
        
        guard let url = baseURL.withQueries(query) else {
            completion(nil)
            print("URL could not be found")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let decoder = JSONDecoder()
            guard let data = data else { print("No data found"); return }
            
            if let storeItems = try? decoder.decode(StoreItems.self, from: data) {
                completion(storeItems.results)
            } else {
                print("Data was not serialized")
                
                completion(nil)
                return
            }
        }
        
        task.resume()
    }
}
