//
//  StoreItem.swift
//  iTunesSearch
//
//  Created by Tyler Gee on 7/27/18.
//  Copyright © 2018 Caleb Hicks. All rights reserved.
//

import Foundation

struct StoreItem: Codable {
    var name: String
    var artist: String
    var kind: String
    var imageURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case kind
        case imageURL = "artworkURL100"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: CodingKeys.name)
        artist = try values.decode(String.self, forKey: CodingKeys.artist)
        kind = try values.decode(String.self, forKey: CodingKeys.kind)
        imageURL = try? values.decode(URL.self, forKey: CodingKeys.imageURL)
    }
}




struct StoreItems: Codable {
    let results: [StoreItem]
}
