//
//  DeveloperEntity.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 9/5/25.
//

/// Represents a game developer.
/// Conforms to `Identifiable` (using 'id' which is 'name') and `Hashable`.
struct DeveloperEntity: Identifiable, Hashable {
    /// The unique identifier for the developer, typically its name.
    let id: String
    let name: String
    let logo: String
    let website: String?

    // Standard initializer
    init(id: String, name: String, logo: String, website: String?) {
        self.id = id
        self.name = name
        self.logo = logo
        self.website = website
    }

    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DeveloperEntity, rhs: DeveloperEntity) -> Bool {
        return lhs.id == rhs.id
    }
}
