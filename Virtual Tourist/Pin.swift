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
    
    static var droppedPins = [ Int16 : Pin ]()
    static var totalPins: Int = 0
    
    init( location: CLLocationCoordinate2D, pin: MKPinAnnotationView, context: NSManagedObjectContext )
    {
        let pinEntity = NSEntityDescription.entityForName(
            "Pin",
            inManagedObjectContext: context
        )!
        
        super.init(
            entity: pinEntity,
            insertIntoManagedObjectContext: context
        )
        
        Pin.totalPins++
        
        pinLatitude = location.latitude
        pinLongitude = location.longitude
        pinNumber = Int16( Pin.totalPins )
        mapPin = pin
        println( "initing with mapPin.annotation: \( pin.annotation )." )
        
        Pin.droppedPins.updateValue( self, forKey: pinNumber )
    }
    
    override init( entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext? )
    {
        super.init(
            entity: entity,
            insertIntoManagedObjectContext: context
        )
    }
    
    class func fetchAllPins()
    {
        println( "fetching all pins..." )
        let fetchError: NSErrorPointer = nil
        
        let pinsFetchRequest = NSFetchRequest( entityName: "Pin" )
        
        let pins: [ AnyObject ] = CoreDataStackManager.sharedInstance().managedObjectContext!.executeFetchRequest(
            pinsFetchRequest,
            error: fetchError
        )!
        println( "pins.count: \( pins.count )" )
        
        if fetchError != nil
        {
            println( "There was an error fetching the pins from Core Data: \( fetchError )." )
        }
        
        var lastPin: Int = 0
        for pin in pins
        {
            println( "Ading \( pin ) to Pin.droppedPins." )
            Pin.droppedPins.updateValue( pin as! Pin, forKey: pin.pinNumber )
            lastPin = Int( pin.pinNumber )
        }
        totalPins = lastPin
    }
}
