//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 8/10/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

import UIKit
import CoreData

@objc( Photo )

class Photo: NSManagedObject
{
    @NSManaged var farmID: Int16
    @NSManaged var serverID: String
    @NSManaged var photoID: String
    @NSManaged var secret: String
    
    init(
        photoDictionary: [ String : AnyObject ],
        context: NSManagedObjectContext
    )
    {
        let photoEntity = NSEntityDescription.entityForName(
            "Photo",
            inManagedObjectContext: context
        )!
        
        super.init(
            entity: photoEntity,
            insertIntoManagedObjectContext: context
        )
        
        // initialize the four properties here
        farmID = photoDictionary[ "farmID" ] as! Int16
        serverID = photoDictionary[ "serverID" ] as! String
        photoID = photoDictionary[ "photoID" ] as! String
        secret = photoDictionary[ "secret" ] as! String
    }
    
    override init(
        entity: NSEntityDescription,
        insertIntoManagedObjectContext context: NSManagedObjectContext?
    )
    {
        super.init(
            entity: entity,
            insertIntoManagedObjectContext: context
        )
    }
}
