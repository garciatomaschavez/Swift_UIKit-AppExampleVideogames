//
//  DeveloperEntity.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

import Foundation

/// Represents a game developer.
/// Conforms to `Identifiable` (using 'id' which is 'name'), `Decodable`, and `Hashable`.
struct DeveloperEntity: Identifiable, Decodable, Hashable {
    /// The unique identifier for the developer, derived from its name from the API.
    let id: String
    let name: String
    let logo: String
    let website: String?

    enum CodingKeys: String, CodingKey {
        case name, logo, website
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        logo = try container.decode(String.self, forKey: .logo)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        id = name // Use the developer's name as its unique ID for the Entity layer
    }

    // Standard initializer
    init(id: String, name: String, logo: String, website: String?) {
        self.id = id
        self.name = name
        self.logo = logo
        self.website = website
    }

    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // id is the 'name'
    }

    static func == (lhs: DeveloperEntity, rhs: DeveloperEntity) -> Bool {
        return lhs.id == rhs.id
    }
}
