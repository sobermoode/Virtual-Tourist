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
    @NSManaged var pinLatitude: Double
    @NSManaged var pinLongitude: Double
    
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
        
        pinLatitude = location.latitude
        pinLongitude = location.longitude
    }
    
    override init( entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext? )
    {
        super.init(
            entity: entity,
            insertIntoManagedObjectContext: context
        )
    }
}
