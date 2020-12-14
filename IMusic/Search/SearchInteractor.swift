//
//  SearchInteractor.swift
//  IMusic
//
//  Created by Андрей on 03.12.2020.
//  Copyright (c) 2020 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var presenter: SearchPresentationLogic?
    var service: SearchService?
    var networkService = NetworkService()
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        if service == nil {
            service = SearchService()
        }
        
        switch request {
        case .getTracks(query: let query):
            networkService.fetchTracks(searchText: query) { [weak self] (response) in
                self?.presenter?.presentData(response: .presentTracks(response: response))
            }
            presenter?.presentData(response: .presentFooterView)
        }
    }
    
}
