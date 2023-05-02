//
//  ProductionCompanyModel.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation

// MARK: - ProductionCompany
struct ProductionCompany: Codable {
    let id: Int
    let logoPath, name, originCountry: String

    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

