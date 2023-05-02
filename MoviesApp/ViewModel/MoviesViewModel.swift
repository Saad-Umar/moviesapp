//
//  MoviesApp.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Foundation
import CoreData

///ViewModel for MoviesAppView
class MoviesViewModel: ObservableObject {
    
    private let persistenceManager: PersistenceManager
    private let service: Service
    private var tmdbConfiguration: TMDBConfiguration?
    
    @MainActor
    @Published var movies: [MovieCoreDataModel] = []
    
    /// Depency injecting persistence manager as it will depend upon the context
    /// Normally we would be using PersistenceManager.shared through out our life cycle
    /// But there can be instances where would want to mock it with something else
    /// For examples, in tests, we would want an inMemory persistence manager with run time dummy data
    init(with service: Service = NetworkService(), persistenceManager: PersistenceManager = PersistenceManager.shared) {
        self.service = service
        self.persistenceManager = persistenceManager
        self.persistenceManager.deleteAllData("MovieCoreDataModel") //clear CoreData for fresh storage
        Task {
            await self.fetchTMDBConfiguration()
            await self.fetchAllMovies()
        }
    }
    
    func retryFetchMovies() {
        self.persistenceManager.deleteAllData("MovieCoreDataModel") //clear CoreData for fresh storage
        Task {
            await self.fetchAllMovies()
        }
    }
    private func getAllPersistentMovies() -> [MovieCoreDataModel] {
        var movies:[MovieCoreDataModel] = []
        // Create a fetch request for the Movie entity
        let fetchRequest: NSFetchRequest<MovieCoreDataModel> = MovieCoreDataModel.fetchRequest()
        
        do {
            // Execute the fetch request on the managed object context
            let fetchedMovies = try persistenceManager.container.viewContext.fetch(fetchRequest)
            
            // Use the fetched objects
            movies = fetchedMovies
        } catch {
            // Handle any errors
            print("Failed to fetch Movies: \(error)")
        }
        return movies
    }
    
    ///Call this function after have successfully retrieved movies from network and set to self.movies
    private func persistAllMovies() {
        do {
            try self.persistenceManager.container.viewContext.save()

        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension MovieCoreDataModel {
    ///Convenience init to initialize Movie Core Data model from the Movie App Model
    convenience init(from model:Movie, with config: TMDBConfiguration?) {
        self.init(context: PersistenceManager.shared.container.viewContext)
        self.id = UUID()
        self.cachedDate = Date()
        self.originalTitle = model.originalTitle
        self.backdropPath = "\(config?.images.secureBaseURL ?? AppURLS.Endpoints.fallbackBaseURL )w500/\(model.backdropPath)"
        self.releaseDate = model.releaseDate
        self.popularity = Int32(model.popularity)
        self.overview = model.overview
    }
    ///Convenience init for empty views
    convenience init(with id: UUID) {
        self.init(context: PersistenceManager.shared.container.viewContext)
        self.id = id
        self.cachedDate = Date()
    }
}

extension MoviesViewModel {
    ///Standard async  function, meant to be awaited  in Task
    @MainActor
    func fetchTMDBConfiguration() async {
        let request = ConfigurationRequest()
        let configuration: TMDBConfiguration?
        
        do {
            let result = try await service.get(request: request)
            
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                configuration = try decoder.decode(TMDBConfiguration.self, from: data)
                tmdbConfiguration = configuration
            case .failure(_):
                break
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
        
    ///Standard async  function, meant to be awaited  in Task
    @MainActor
    func fetchAllMovies() async {
        let request = MoviesRequest()
        var fetchedMovies:[MovieCoreDataModel] = []
        
        do {
            let result = try await service.get(request: request)
            
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                fetchedMovies = try decoder.decode(MoviesListModel.self, from: data).results.movies(with:self.tmdbConfiguration)
            case .failure(_):
                break
            }
        } catch {
            print(error.localizedDescription)
        }
        if !fetchedMovies.isEmpty {
            self.movies = fetchedMovies
            //TODO: do the below fix and call this function to saving the movies model in CoreData
            //self.persistAllMovies()
        } //else {
        //FIXME: Complete the following implementation to have the user at least see last fetched api response, incase off no internet :)
//            let persistentmovies = getAllPersistentMovies()
//            if !persistentMovies.isEmpty {
//                self.movies = persistentMovies
//            }
//        }
    }
}



extension Array where Element == Movie {
    ///Converts the given Movie Array to Movie Array
    ///Distinguish: Movie is app model where as Movie is Core Data model
    func movies(with config:TMDBConfiguration?) -> [MovieCoreDataModel] {
        var movies: [MovieCoreDataModel] = []
        for item in self {
            movies.append(MovieCoreDataModel(from: item, with: config))
        }
        return movies
    }
}
