//
//  NetworkRequests.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation

///Concrete request to get all movies
///Discussion: We are not passing any value for cachePolicy in URLRequest.init() which defaults to useProtocolCachePolicy
///which is well illustrated in Figure 1 here: https://developer.apple.com/documentation/foundation/nsurlrequest/cachepolicy/useprotocolcachepolicy

struct MoviesRequest: Request {
    var urlRequest: URLRequest {
        let url = URL(string: AppURLS.Endpoints.movies)
        let urlRequest = URLRequest(url: url!)
        return urlRequest
    }
}

struct ConfigurationRequest: Request {
    var urlRequest: URLRequest {
        let url = URL(string: AppURLS.Endpoints.configuration)
        let urlRequest = URLRequest(url: url!)
        return urlRequest
    }
}
