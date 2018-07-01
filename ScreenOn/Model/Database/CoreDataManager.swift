//
//  CoreDataManager.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let appName = "ScreenOn"
    
    private lazy var context: NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            let container = NSPersistentContainer(name: self.appName)
            container.loadPersistentStores(completionHandler: { (desc, error) in
                if let err = error {
                    print("Failed to load persistent store to core data context due to: \(err)")
                }
            })
            return container.viewContext
        } else {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            do {
                context.persistentStoreCoordinator = try NSPersistentStoreCoordinator.coordinator(named: self.appName)
            } catch let error {
                fatalError("Failed to add persistent store coordinator to core data context due to: \(error)")
            }
            return context
        }
        
    }()
    
    func saveContext () {
        if self.context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Failed to save data to core data context due to: \(error)")
            }
        }
    }
    
}
