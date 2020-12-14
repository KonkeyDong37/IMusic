//
//  SearchResponse.swift
//  IMusic
//
//  Created by Андрей on 02.12.2020.
//

import Foundation

struct SearchResponseModel: Decodable {
    var resultCount: Int
    var results: [TrackModel]
}

struct TrackModel: Decodable {
    var artistName: String
    var trackName: String?
    var collectionName: String?
    var artworkUrl100: String?
    var previewUrl: String?
}
