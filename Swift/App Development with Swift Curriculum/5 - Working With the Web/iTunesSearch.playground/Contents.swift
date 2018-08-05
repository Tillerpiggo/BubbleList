//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct StoreItem: Codable {
    var wrapperType: String
    
    enum CodingKeys: String, CodingKey {
        case wrapperType
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        wrapperType = try values.decode(String.self, forKey: CodingKeys.wrapperType)
    }
}

struct StoreItems: Codable {
    let results: [StoreItem]
}

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





extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.compactMap { URLQueryItem(name: $0.0, value: $0.1) }
        
        return components?.url
    }
}

let myQuery: [String: String] = [
    "term": "be",
    "country": "US"
]

fetchItems(matching: myQuery, completion: { (storeItems) in
    if let storeItems = storeItems {
        for storeItem in storeItems {
            print(storeItem)
        }
    } else {
        print("Oops. Something went wrong.")
    }
})

