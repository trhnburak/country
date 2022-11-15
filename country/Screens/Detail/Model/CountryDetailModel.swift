//
//  CountryDetailModel.swift
//  adesso
//
//  Created by Burak Turhan on 12.11.2022.
//

import Foundation

// MARK: - CountryDetailModel
struct CountryDetailModel: Decodable {
    var data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    var code, callingCode: String?
    var currencyCodes: [String]?
    var flagImageURI: String?
    var name: String?
    var numRegions: Int?
    var wikiDataID: String?

    enum CodingKeys: String, CodingKey {
        case code, callingCode, currencyCodes
        case flagImageURI = "flagImageUri"
        case name, numRegions
        case wikiDataID = "wikiDataId"
    }
}
