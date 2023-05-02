//
//  AppURLS.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation

///Helper functions
enum AppURLS {
    static func documentsDirectory() -> URL {
        guard let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
            fatalError("Unable to get system docs directory - serious problem")
        }
        return URL(fileURLWithPath: docsPath)
    }
    
    enum Endpoints {
        static let configuration = "https://api.themoviedb.org/3/configuration?api_key=c9856d0cb57c3f14bf75bdc6c063b8f3"
        static let movies = "https://api.themoviedb.org/3/discover/movie?api_key=c9856d0cb57c3f14bf75bdc6c063b8f3"
        static let fallbackBaseURL = "https://image.tmdb.org/t/p/"
    }
}
