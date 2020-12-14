//
//  SearchPresenter.swift
//  IMusic
//
//  Created by Андрей on 03.12.2020.
//  Copyright (c) 2020 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchPresentationLogic {
    func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
    weak var viewController: SearchDisplayLogic?
    
    func presentData(response: Search.Model.Response.ResponseType) {
        
        switch response {
        case .presentTracks(response: let response):
            let cells = response?.results.map({ track in
                cellViewModel(from: track)
            }) ?? []
            let searchViewModel = SearchViewModel.init(cells: cells)
            
            viewController?.displayData(viewModel: .dispalyTracks(searchViewModel: searchViewModel))
        case .presentFooterView:
            viewController?.displayData(viewModel: .displayFooterView)
        }
    }
    
    private func cellViewModel(from track: TrackModel) -> SearchViewModel.Cell {
        return SearchViewModel.Cell.init(
            artistName: track.artistName,
            trackName: track.trackName ?? "",
            collectionName: track.collectionName ?? "",
            iconUrlString: track.artworkUrl100 ?? "",
            previewUrl: track.previewUrl ?? ""
        )
    }
    
}
