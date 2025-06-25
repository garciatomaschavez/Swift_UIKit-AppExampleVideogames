//
//  DataLayerDependencies.swift
//  UIKit-AppExampleVideogames
//
//  Created by tom on 23/05/25.
//

import Foundation
import CoreData

/// A container for managing and providing data layer dependencies.
struct DataLayerDependencies {
    let videogameLocalDataSource: VideogameLocalDataSourceProtocol
    let developerLocalDataSource: DeveloperLocalDataSourceProtocol
    let videogameRemoteDataSource: APIServiceProtocol
    
    let videogameRepository: any VideogameRepository
    let developerRepository: any DeveloperRepository // Added for completeness, though not used by current list/detail interactors

    init(persistentContainer: NSPersistentContainer, fetchStrategy: FetchStrategy = .remoteElseLocal) {
        // CoreData Service
        let coreDataService = CoreDataService(persistentContainer: persistentContainer)

        // Data Sources
        self.videogameLocalDataSource = VideogameLocalDataSource(coreDataService: coreDataService, persistentContainer: persistentContainer)
        self.developerLocalDataSource = DeveloperLocalDataSource(coreDataService: coreDataService, persistentContainer: persistentContainer)
        self.videogameRemoteDataSource = APIService() // APIService conforms to VideogameRemoteDataSourceProtocol

        // Repositories
        self.videogameRepository = DefaultVideogameRepositoryImpl(
            videogameLocalDataSource: self.videogameLocalDataSource,
            developerLocalDataSource: self.developerLocalDataSource,
            remoteDataSource: self.videogameRemoteDataSource,
            fetchStrategy: fetchStrategy
        )
        self.developerRepository = DefaultDeveloperRepositoryImpl(
            localDataSource: self.developerLocalDataSource as! DeveloperLocalDataSource
        )
    }
}
