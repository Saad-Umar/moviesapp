//
//  TMDBConfigurationModel.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation

// MARK: - Welcome
struct TMDBConfiguration: Codable {
    let images: TMDBImages
    let changeKeys: [String]

    enum CodingKeys: String, CodingKey {
        case images
        case changeKeys = "change_keys"
    }
}

// MARK: - Images
struct TMDBImages: Codable {
    let baseURL: String
    let secureBaseURL: String
    let backdropSizes, logoSizes, posterSizes, profileSizes: [String]
    let stillSizes: [String]

    enum CodingKeys: String, CodingKey {
        case baseURL = "base_url"
        case secureBaseURL = "secure_base_url"
        case backdropSizes = "backdrop_sizes"
        case logoSizes = "logo_sizes"
        case posterSizes = "poster_sizes"
        case profileSizes = "profile_sizes"
        case stillSizes = "still_sizes"
    }
}
