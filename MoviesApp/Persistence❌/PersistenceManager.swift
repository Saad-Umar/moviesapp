//
//  PersistenceManager.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import CoreData
import SwiftUI

///Designed specifically for future cases where we would be having a need to persist data locally, right now not using it the way it is meant to be used . :)
class PersistenceManager:NSObject {
    static let shared = PersistenceManager()
    
    private(set) var isPreviewContext = false
    
    //lazily initialize a PersistenceController with Dummy data for SwiftUI Canvas based testing 
    static var preview: PersistenceManager = {
        let names = ["Shawshank Redemption", "The Dark Knight", "Fast X", "One flew over cuckoo's nest", "Hitman", "Mission Impossible: Ghost Protocol", "Eternal Sunshine of Spotless mind"]
        let dates = ["03/02/1999", "03/02/1999", "03/02/1999", "03/01/1999", "03/04/1999", "03/02/1999", "03/05/1999"]
        let result = PersistenceManager(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = MovieCoreDataModel(context: viewContext)
            newItem.id = UUID()
            newItem.cachedDate = Date()
            newItem.originalTitle = names[Int.random(in: 0...6)]
            newItem.releaseDate = dates[Int.random(in: 0...6)]
            newItem.originalLanguage = "English"
            newItem.stars = Int32.random(in: 10...10000)
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    private(set) var container: NSPersistentContainer = NSPersistentContainer(name: "MoviesApp")

    /// Initialize a store.
    ///
    /// - Parameters:
    ///     - inMemory: if true, initialize a temporary store for transient data. If false makes a permanent store for persisting data
    init(inMemory: Bool = false, forPreviewProvider: Bool = false) {
        super.init()
        if forPreviewProvider {
            return
        }
        
        self.isPreviewContext = inMemory //We are using inMemory only for testing, always using disk for runtime
        configureContainer()
        container = NSPersistentContainer(name: "MoviesApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func configureContainer() {
        let preview = URL(fileURLWithPath: "/dev/null")
        let prod = AppURLS.documentsDirectory().appendingPathComponent("movies.sqlite")
        let url = isPreviewContext ? preview:prod
        let storeDescription = makeStore(at: url)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { _, error in
            if let error = error {
                print("error: in core data load", error)
            }
            self.container.viewContext.undoManager = UndoManager()
        }
    }
    
    func makeStore(at url: URL) -> NSPersistentStoreDescription {
        let storeDescription = NSPersistentStoreDescription(url: url)
        if isPreviewContext {
            storeDescription.type = NSInMemoryStoreType
        } else {
            storeDescription.type = NSSQLiteStoreType
        }
        return storeDescription
    }
    
    func deleteAllData(_ entity:String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        let predicate = NSPredicate(format: "cachedDate < %@", NSDate())
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try self.container.persistentStoreCoordinator.execute(deleteRequest, with: self.container.viewContext)
        } catch {
            print(error.localizedDescription)
        }
    }
}
