//
//  APIVideogameDTO.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

/// Data Transfer Object (DTO) representing a videogame as returned by the API.
/// This struct should exactly match the structure of a videogame object in the API's JSON response.
struct APIVideogameDTO: Decodable {
    let title: String
    /// The description of the videogame, matching the "description" field in the JSON.
    let description: String
    let releaseYear: String
    /// The nested developer DTO.
    let developer: APIDeveloperDTO
    let platforms: [String]
    let logo: String
    let screenshotIdentifiers: [String]
}
