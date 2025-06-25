//
//  APIDeveloperDTO.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

/// Data Transfer Object (DTO) representing a developer as returned by the API.
/// This struct should exactly match the structure of the developer object in the API's JSON response.
struct APIDeveloperDTO: Decodable {
    let name: String
    let logo: String
    let website: String?
}
