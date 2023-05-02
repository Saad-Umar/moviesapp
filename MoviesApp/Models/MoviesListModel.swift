//
//  MainModel.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation

struct MoviesListModel: Codable {
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
