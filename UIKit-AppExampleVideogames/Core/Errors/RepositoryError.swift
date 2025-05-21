//
//  RepositoryError.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 16/5/25.
//

import Foundation

/// Enum defining possible errors that can occur during repository operations.
enum RepositoryError: Error {
    /// Encapsulates an error that occurred during a network request.
    case networkError(Error)
    /// Encapsulates an error that occurred while decoding data (e.g., parsing JSON).
    case decodingError(Error)
    /// Encapsulates an error originating from CoreData operations.
    case coreDataError(Error)
    /// Indicates that the requested data could not be found.
    case dataNotFound
    /// Represents an unknown or unspecified error.
    case unknown(Error? = nil)
    /// Indicates an issue with loading a local resource, like a bundled JSON file.
    case localResourceError(String)
}
