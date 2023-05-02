//
//  SpokenLanguageModel.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation

// MARK: - SpokenLanguage
struct SpokenLanguage: Codable {
    let englishName, iso639_1, name: String

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso639_1 = "iso_639_1"
        case name
    }
}

enum OriginalLanguage: String, Codable {
    case en = "en"
    case es = "es"
    case ko = "ko"
    case nl = "nl"
}
