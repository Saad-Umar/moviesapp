//
//  ProductionCountryModel.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation

// MARK: - ProductionCountry
struct ProductionCountry: Codable {
    let iso3166_1, name: String

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}
