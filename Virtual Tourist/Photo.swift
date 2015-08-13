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
    @NSManaged var farmID: NSNumber
    @NSManaged var serverID: String
    @NSManaged var photoID: String
    @NSManaged var secret: String
    
    @NSManaged var destination: Pin!
    var photoURLString: String
    {
        // let farmNumber = farmID.integerValue
        // println( farmNumber )
        return "https://farm\( farmID ).staticflickr.com/\( serverID )/\( photoID )_\( secret ).jpg"
    }
    // var photoURLString: String!
    var photoURL: NSURL!
    {
        return NSURL( string: photoURLString )!
    }
    // var albumImage: UIImage!
    var albumImage: UIImage? = nil
    
    init(
        photoDictionary: [ String : AnyObject ],
        destinationPin: Pin,
        context: NSManagedObjectContext
    )
    {
        println( "Initializing a new Photo..." )
        let photoEntity = NSEntityDescription.entityForName(
            "Photo",
            inManagedObjectContext: context
        )!
        
        super.init(
            entity: photoEntity,
            insertIntoManagedObjectContext: context
        )
        
        destination = destinationPin
        // let farm = photoDictionary[ "farmID" ] as! CInt
        // let intmax = farm.toIntMax()
        // farmID = Int16( intmax )
        farmID = photoDictionary[ "farmID" ] as! Int
        // farmID = Int16( farm.integerValue )
        serverID = photoDictionary[ "serverID" ] as! String
        photoID = photoDictionary[ "photoID" ] as! String
        secret = photoDictionary[ "secret" ] as! String
        // photoURLString = "https://farm\( farmID ).staticflickr.com/\( serverID )/\( photoID )_\( secret ).jpg"
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
    
    class func fetchAllPhotos() -> [ Photo ]
    {
        println( "fetching all photos..." )
        let fetchError: NSErrorPointer = nil
        
        let photosFetchRequest = NSFetchRequest( entityName: "Photo" )
        
        let photos: [ AnyObject ] = CoreDataStackManager.sharedInstance().managedObjectContext!.executeFetchRequest(
            photosFetchRequest,
            error: fetchError
            )!
        println( "photos.count: \( photos.count )" )
        
        if fetchError != nil
        {
            println( "There was an error fetching the pins from Core Data: \( fetchError )." )
        }
        
        return photos as! [ Photo ]
        
//        var lastPhoto: Int = 0
//        for photo in photos
//        {
//            // println( "Adding \( pin ) to Pin.droppedPins." )
//            // Pin.droppedPins.updateValue( pin as! Pin, forKey: pin.pinNumber )
//            // lastPhoto = Int( pin.pinNumber )
//        }
//        totalPins = lastPin
    }
}
