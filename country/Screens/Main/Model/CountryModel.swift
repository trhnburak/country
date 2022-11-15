//
//  CountryModel.swift
//  adesso
//
//  Created by Burak Turhan on 10.11.2022.
//

import Foundation

// MARK: - CountryModel
struct CountryModel: Decodable {
    var data: [Data]?
    var links: [Link]?
    var metadata: Metadata?
}

// MARK: - Results
struct Data: Decodable {
    var code: String?
    var currencyCodes: [String]?
    var name: String?
    var wikiDataID: String?
    var flagImageUri: String?

    enum CodingKeys: String, CodingKey {
        case code, currencyCodes, name
        case wikiDataID = "wikiDataId"
    }
}

// MARK: - Link
struct Link: Decodable {
    var rel, href: String?
}

// MARK: - Metadata
struct Metadata: Decodable {
    var currentOffset, totalCount: Int?
}
