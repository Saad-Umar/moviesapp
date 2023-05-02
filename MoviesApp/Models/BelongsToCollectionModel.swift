//
//  BelongsToCollectionType.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation

// MARK: - BelongsToCollection
struct BelongsToCollection: Codable {
    let id: Int
    let name, posterPath, backdropPath: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}
