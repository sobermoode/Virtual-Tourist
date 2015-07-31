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
    @NSManaged var pinNumber: Int16
    @NSManaged var mapPin: MKPinAnnotationView
    
    init( location: CLLocationCoordinate2D, number: Int16, pin: MKPinAnnotationView, context: NSManagedObjectContext )
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
        pinNumber = number
        mapPin = pin
    }
    
    override init( entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext? )
    {
        super.init(
            entity: entity,
            insertIntoManagedObjectContext: context
        )
    }
}
