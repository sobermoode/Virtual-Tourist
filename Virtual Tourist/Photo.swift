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
    
    var destination: Pin!
    var photoURLString: String
    {
        return "https://farm\( farmID ).staticflickr.com/\( serverID )/\( photoID )_\( secret ).jpg"
    }
    var photoURL: NSURL!
    {
        return NSURL( string: photoURLString )!
    }
    var albumImage: UIImage!
    
    init(
        photoDictionary: [ String : AnyObject ],
        destinationPin: Pin,
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
        
        destination = destinationPin
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
