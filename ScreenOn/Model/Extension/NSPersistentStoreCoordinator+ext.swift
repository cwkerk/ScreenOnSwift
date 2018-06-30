//
//  NSPersistentStoreCoordinator+ext.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentStoreCoordinator {
    
    public enum NSPersistentStoreCoordinatorError: Error {
        case dataModelNotFoundError
        case dataModelCreationError
        case datamodelStorePathError
    }
    
    class func coordinator(named name: String, ext: String? = "momd") throws -> NSPersistentStoreCoordinator {
        guard let dataModelURL = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw NSPersistentStoreCoordinatorError.dataModelNotFoundError
        }
        guard let dataModel = NSManagedObjectModel(contentsOf: dataModelURL) else {
            throw NSPersistentStoreCoordinatorError.dataModelCreationError
        }
        guard var storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSPersistentStoreCoordinatorError.datamodelStorePathError
        }
        storeURL = storeURL.appendingPathComponent("\(name).sqlite")
        let opts = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        let coordinator = NSPersistentStoreCoordinator.init(managedObjectModel: dataModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: opts)
            return coordinator
        } catch {
            throw error
        }
    }
    
}
