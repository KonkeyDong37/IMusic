//
//  SearchModels.swift
//  IMusic
//
//  Created by Андрей on 03.12.2020.
//  Copyright (c) 2020 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SwiftUI

enum Search {
    
    enum Model {
        struct Request {
            enum RequestType {
                case getTracks(query: String)
            }
        }
        struct Response {
            enum ResponseType {
                case presentTracks(response: SearchResponseModel?)
                case presentFooterView
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case dispalyTracks(searchViewModel: SearchViewModel)
                case displayFooterView
            }
        }
    }
}

class SearchViewModel: NSObject, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(cells, forKey: "cells")
    }
    
    required init?(coder: NSCoder) {
        cells = coder.decodeObject(forKey: "cells") as? [SearchViewModel.Cell] ?? []
    }
    
    @objc(_TtCC6IMusic15SearchViewModel4Cell)class Cell: NSObject, NSCoding, Identifiable {
        
        var id = UUID()
        var artistName: String
        var trackName: String
        var collectionName: String
        var iconUrlString: String?
        var previewUrl: String
        
        init(artistName: String,
             trackName: String,
             collectionName: String,
             iconUrlString: String?,
             previewUrl: String) {
            self.artistName = artistName
            self.trackName = trackName
            self.collectionName = collectionName
            self.iconUrlString = iconUrlString
            self.previewUrl = previewUrl
        }
        
        func encode(with coder: NSCoder) {
            coder.encode(artistName, forKey: "artistName")
            coder.encode(trackName, forKey: "trackName")
            coder.encode(collectionName, forKey: "collectionName")
            coder.encode(iconUrlString, forKey: "iconUrlString")
            coder.encode(previewUrl, forKey: "previewUrl")
        }
        
        required init?(coder: NSCoder) {
            artistName = coder.decodeObject(forKey: "artistName") as? String ?? ""
            trackName = coder.decodeObject(forKey: "trackName") as? String ?? ""
            collectionName = coder.decodeObject(forKey: "collectionName") as? String ?? ""
            iconUrlString = coder.decodeObject(forKey: "iconUrlString") as? String? ?? ""
            previewUrl = coder.decodeObject(forKey: "previewUrl") as? String ?? ""
        }
        
    }
    
    init(cells: [Cell]) {
        self.cells = cells
    }
    
    let cells: [Cell]
    
}
