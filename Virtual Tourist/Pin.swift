//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 7/30/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@objc( Pin )

class Pin: NSManagedObject
{
    @NSManaged var coordinate: CLLocationCoordinate2D
    
    init( location: CLLocationCoordinate2D, context: NSManagedObjectContext )
    {
        let coordinateEntity = NSEntityDescription.entityForName(
            "Pin",
            inManagedObjectContext: context
        )!
        
        super.init(
            entity: coordinateEntity,
            insertIntoManagedObjectContext: context
        )
        
        coordinate = location
    }
    
    override init( entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext? )
    {
        super.init(
            entity: entity,
            insertIntoManagedObjectContext: context
        )
    }
}
