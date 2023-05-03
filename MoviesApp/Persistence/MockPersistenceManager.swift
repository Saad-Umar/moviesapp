//
//  MockPersistenceManager.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import CoreData

class MockPersistenceManager:NSObject, PersistenceManager {
    
    static let shared = MockPersistenceManager()
    
    private(set) var container: NSPersistentContainer = NSPersistentContainer(name: "MoviesApp")
    
    
    //lazily initialize a PersistenceController with Dummy data for SwiftUI Canvas based testing
    lazy var preview: MockPersistenceManager = {
        configureContainer()
        let names = ["Shawshank Redemption", "The Dark Knight", "Fast X", "One flew over cuckoo's nest", "Hitman", "Mission Impossible: Ghost Protocol", "Eternal Sunshine of Spotless mind"]
        let dates = ["03/02/1999", "03/02/1999", "03/02/1999", "03/01/1999", "03/04/1999", "03/02/1999", "03/05/1999"]
        let result = MockPersistenceManager()
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = MovieCoreDataModel(context: viewContext)
            newItem.id = UUID()
            newItem.cachedDate = Date()
            newItem.originalTitle = names[Int.random(in: 0...6)]
            newItem.releaseDate = dates[Int.random(in: 0...6)]
            newItem.originalLanguage = "English"
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
    
    
    func configureContainer() {
        let url = URL(fileURLWithPath: "/dev/null")
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
        storeDescription.type = NSInMemoryStoreType
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
