//
//  CDHelper.swift
//  FunderList
//
//  Created by Jay Lingelbach on 1/27/16.
//  Copyright © 2016 Jay Lingelbach. All rights reserved.
//

import Foundation
import CoreData

class CDHelper{
    
    static let sharedInstance = CDHelper()
    
    lazy var storesDirectory: NSURL = {
        let fm = NSFileManager.defaultManager()
        let urls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    lazy var localStoreURL: NSURL = {
        let url = self.storesDirectory.URLByAppendingPathComponent("MasterDetail.sqlite")
        return url
    }()
    lazy var modelURL: NSURL = {
        let bundle = NSBundle.mainBundle()
        if let url = bundle.URLForResource("FunderList", withExtension: "momd") {
            return url
        }
        print("CRITICAL - Managed Object Model file not found")
        abort()
    }()
    
    lazy var model: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL:self.modelURL)!
    }()
    
    lazy var coordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.localStoreURL, options: nil)
        } catch {
            print("Could not add the peristent store")
            abort()
        }
        
        return coordinator
    }()
}