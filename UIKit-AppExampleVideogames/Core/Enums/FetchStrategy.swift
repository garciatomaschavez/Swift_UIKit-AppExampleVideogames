//
//  FetchStrategy.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/05/25.
//

import Foundation

/// Defines the strategy for fetching data when multiple sources (local, remote) are available.
enum FetchStrategy {
    /// Fetches data only from the local data source.
    case localOnly
    /// Fetches data only from the remote data source.
    case remoteOnly
    /// Fetches data from the local data source first, then updates from the remote data source.
    /// The completion handler might be called twice: once with local data, once with updated remote data.
    case localThenRemote
    /// Fetches data from the remote data source first. If it fails, falls back to the local data source.
    case remoteElseLocal
}
