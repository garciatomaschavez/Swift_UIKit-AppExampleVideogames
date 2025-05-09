//
//  Platforms.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 30/4/25.
//

import Foundation

/// Represents the gaming platforms.
/// This enum is part of the Domain layer and can be used by Entities and Use Cases.
public enum Platform: String, CaseIterable, Codable, Equatable, Hashable {
    case pc = "PC"
    case playstation = "PlayStation"
    case xbox = "Xbox"
    case nintendoSwitch = "Nintendo Switch"
    case iOS = "iOS"
    case android = "Android"
    case steam = "Steam"
    // Add any other platforms you might need, e.g., macos, linux

    /// A display-friendly name for the platform.
    /// In a more complex app, this might come from a localization file.
    public var displayName: String {
        return self.rawValue
    }

    /// The name of the image asset associated with this platform.
    /// This provides a link to the UI representation without making the Domain dependent on UIKit.
    /// The actual UIImage loading would happen in the Presentation layer.
    public var imageName: String {
        switch self {
        case .pc:
            return "pc"
        case .playstation:
            return "playstation"
        case .xbox:
            return "xbox"
        case .nintendoSwitch:
            return "nintendoswitch"
        case .iOS:
            return "ios"
        case .android:
            return "android"
        case .steam:
            return "steam"
        // default: return "missing" // Or handle new cases explicitly
        }
    }
}
