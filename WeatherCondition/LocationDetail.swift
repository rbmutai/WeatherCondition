//
//  LocationDetail.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 14/01/2025.
//

import Foundation

struct LocationDetail: Decodable {
    let results: [ResultDetail]
}

struct ResultDetail: Decodable {
    let addressComponents: [AddressDetail]
    let formattedAddress: String
    
    enum CodingKeys: String, CodingKey {
         case addressComponents = "address_components"
         case formattedAddress = "formatted_address"
    }
}

struct AddressDetail: Decodable {
    let longName: String
    let types: [String]
    
    enum CodingKeys:String, CodingKey {
        case longName = "long_name"
        case types
    }
}
