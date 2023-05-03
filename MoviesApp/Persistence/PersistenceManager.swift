//
//  PersistenceManager.swift
//  MoviesApp
//
//  Created by Saad Umar on 5/3/23.
//

import CoreData

protocol PersistenceManager {
    var container: NSPersistentContainer {get}

    func configureContainer()
    func makeStore(at url: URL) -> NSPersistentStoreDescription
    func deleteAllData(_ entity:String)
}
