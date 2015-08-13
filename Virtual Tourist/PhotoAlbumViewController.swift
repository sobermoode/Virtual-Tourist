//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 8/4/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

// TODO: there's still a bug when removing pictures multiple times; eventually, the number of pictures in the album
// and the number being returned by collectionView:numberOfItemsInSection() is not matching, therefore crashing the app.

// TODO: make a dummy dictionary to use to initialize the Photo array with capacity

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var destinationMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var destinationImagesCollection: UICollectionView!
    
    // var destination: CLLocationCoordinate2D!
    var destination: Pin!
    
    lazy var sharedContext: NSManagedObjectContext =
    {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    // TODO: use currentPhotoAlbum.count instead, or 30 if it's greater than that
    var maxAlbumPhotos: Int = 30
    
    let flickrQuery = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=71549104e5500eb7d194d040cc55ea10&lat=33.862237&lon=-118.399519&format=json&nojsoncallback=1"
    let flickrAPIBaseURL = "https://api.flickr.com/services/rest/?"
    let flickrAPIMethod = "flickr.photos.search"
    let flickrAPIKey = "71549104e5500eb7d194d040cc55ea10"
    let flickrAPILatitude = "33.862237"
    let flickrAPILongitude = "118.399519"
    let flickrAPIPage = "1"
    let flickrAPIPerPage = "250"
    let flickrAPIFormat = "json"
    let flickrAPICallback = "1"
    
    var flickrResultsPages: Int = 0
    var flickrResultsPerPage: Int = 0
    var flickrResultsPhotos: [ [ String : AnyObject ] ] = []
    // var currentPhotoAlbum: [ UIImage? ] = []
    var currentPhotoAlbum: [ Photo ] = []
    var currentResultsPage: Int = 1
    
    let dummyPhotoDictionary: [ String : AnyObject ] =
    [
        "farmID" : 9999,
        "serverID" : "9999",
        "photoID" : "9999",
        "secret" : "XXXX"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var navItem = UINavigationItem( title: "Photo Album" )
        
        let backButton = UIBarButtonItem(
            title: "Back to Map",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "backToMap:"
        )
        
        navItem.leftBarButtonItem = backButton
        
        navBar.items = [ navItem ]
        
        destinationMap.region = MKCoordinateRegion(
            center: destination.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.1,
                longitudeDelta: 0.1
            )
        )
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destination.coordinate
        
        destinationMap.addAnnotation( destinationAnnotation )
        
        destinationImagesCollection.allowsMultipleSelection = true
        destinationImagesCollection.dataSource = self
        destinationImagesCollection.delegate = self
        
        newCollectionButton.addTarget(
            self,
            action: "newCollection",
            forControlEvents: .TouchUpInside
        )
        
        if !destination.photoCollection.isEmpty
        {
            currentPhotoAlbum = destination.photoCollection
        }
        else
        {
            requestInitialPhotoAlbum()
        }
        
        // code for requestInitialPhotoAlbum was here, originally
        
        // destination.photoCollection = currentPhotoAlbum
        // CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func requestInitialPhotoAlbum()
    {
        let flickrURL = NSURL( string: flickrQuery )!
        
        let flickrTask = NSURLSession.sharedSession().dataTaskWithURL( flickrURL )
        {
            flickrData, flickrResponse, flickrError in
            
            if flickrError != nil
            {
                println( "There was an error with the Flickr request: \( flickrError )" )
            }
            else
            {
                var jsonificationError: NSErrorPointer = nil
                if let results = NSJSONSerialization.JSONObjectWithData(
                    flickrData,
                    options: nil,
                    error: jsonificationError
                    ) as? [ String : AnyObject ]
                {
                    let photos = results[ "photos" ] as! [ String : AnyObject ]
                    self.flickrResultsPages = photos[ "pages" ] as! Int
                    self.flickrResultsPerPage = photos[ "perpage" ] as! Int
                    self.flickrResultsPhotos = photos[ "photo" ] as! [ [ String : AnyObject ] ]
                    println( "flickrResultsPhotos.count: \( self.flickrResultsPhotos.count )" )
                    
                    // set the initial photo album to the first 30 images (or max that was returned if less)
                    // for every subsequent request for a new collection, test for ( remainingInPage - 30 > 0 )
                    // and if not, that ( remainingPages > 0 ), and get the next 30 photos or the first 30 from
                    // the next page. then update remainingInPage and remainingPages.
                    // var photoURLs: [ NSURL ] = []
                    var initialAlbumMax = ( self.flickrResultsPhotos.count > 30 ) ? 30 : self.flickrResultsPhotos.count
                    // self.currentPhotoAlbum = [ Photo? ]( count: initialAlbumMax-1, repeatedValue: nil )
                    println( "Initing self.currentPhotoAlbum with \( initialAlbumMax ) photos..." )
                    self.currentPhotoAlbum = [ Photo ]( count: initialAlbumMax, repeatedValue: Photo(photoDictionary: self.dummyPhotoDictionary, destinationPin: self.destination, context: self.sharedContext) )
                    for initialAlbumCounter in 0...initialAlbumMax-1
                    {
                        println( "Adding actual Photos..." )
                        let currentPhoto = self.flickrResultsPhotos[ initialAlbumCounter ] as [ String : AnyObject ]
                        let farmID = currentPhoto[ "farm" ] as! NSNumber
                        // let farmNumber = farmID.intValue
                        let serverID = currentPhoto[ "server" ] as! String
                        let photoID = currentPhoto[ "id" ] as! String
                        let secret = currentPhoto[ "secret" ] as! String
                        
                        var photoInfo: [ String : AnyObject ] = [ : ]
                        photoInfo.updateValue( farmID, forKey: "farmID" )
                        photoInfo.updateValue( serverID, forKey: "serverID" )
                        photoInfo.updateValue( photoID, forKey: "photoID" )
                        photoInfo.updateValue( secret, forKey: "secret" )
                        
                        let newPhoto = Photo(
                            photoDictionary: photoInfo,
                            destinationPin: self.destination,
                            context: self.sharedContext
                        )
                        
                        // let photoURLString = "https://farm\( farmID! ).staticflickr.com/\( serverID! )/\( photoID! )_\( secret! ).jpg"
                        // let photoURL = NSURL( string: photoURLString )!
                        // photoURLs.append( photoURL )
                        // photoURLs.append( newPhoto.photoURL )
                        // self.currentPhotoAlbum.append( newPhoto )
                        self.currentPhotoAlbum[ initialAlbumCounter ] = newPhoto
                    }
                    
                    // self.currentPhotoAlbum = [ UIImage? ]( count: photoURLs.count, repeatedValue: nil )
                    var currentURLCounter = 0
                    for currentPhoto1 in self.currentPhotoAlbum
                    {
                        println( "currentPhoto: \( currentPhoto1 )" )
                        println( "currentPhoto.photoURL: \( currentPhoto1.photoURL )" )
                        if let currentURL = currentPhoto1.photoURL
                        {
                            dispatch_async( dispatch_get_main_queue() )
                            {
                                let photoTask = NSURLSession.sharedSession().dataTaskWithURL( currentURL )
                                {
                                    photoData, photoResponse, photoError in
                                    
                                    if photoError != nil
                                    {
                                        println( "There was an error getting the image from Flickr: \( photoError )." )
                                    }
                                    else
                                    {
                                        currentPhoto1.albumImage = UIImage( data: photoData )
                                        self.currentPhotoAlbum[ currentURLCounter ] = currentPhoto1
                                    }
                                    
                                    currentURLCounter++
                                }
                                photoTask.resume()
                                CoreDataStackManager.sharedInstance().saveContext()
                                // self.destinationImagesCollection.reloadData()
                            }
                        }
                    }
                }
                else
                {
                    println( "There was a problem parsing the results from Flickr." )
                }
            }
        }
        flickrTask.resume()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func backToMap( sender: UIBarButtonItem )
    {
        dismissViewControllerAnimated(
            true,
            completion: nil
        )
    }
    
    func collectionView(
        collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int
    {
        return maxAlbumPhotos
    }
    
    func collectionView(
        collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath
    ) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "photoAlbumImageCell",
            forIndexPath: indexPath
        ) as! PhotoAlbumImageCell
        
        cell.frame.size.width = ( collectionView.collectionViewLayout.collectionViewContentSize().width / 3 ) - 10
        cell.frame.size.height = cell.frame.size.width
        
        if currentPhotoAlbum.isEmpty
        {
            return cell
        }
        
//        if currentPhotoAlbum[ indexPath.item ] != nil
//        {
//            let currentPhoto = currentPhotoAlbum[ indexPath.item ]
//            cell.destinationImage.contentMode = UIViewContentMode.ScaleAspectFill
//            cell.destinationImage.image = currentPhoto?.albumImage
//        }
        if currentPhotoAlbum[ indexPath.item ].albumImage != nil
        {
            cell.destinationImage.contentMode = UIViewContentMode.ScaleAspectFill
            cell.destinationImage.image = currentPhotoAlbum[ indexPath.item ].albumImage
        }
        
        cell.alpha = ( cell.selected ) ? 0.35 : 1.0
        
        return cell
    }
    
    func collectionView(
        collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath
    )
    {
        let cell = collectionView.cellForItemAtIndexPath( indexPath ) as! PhotoAlbumImageCell
        
        cell.alpha = 0.35
        
        if collectionView.indexPathsForSelectedItems().count > 0
        {
            newCollectionButton.setTitle(
                "Remove Selected Pictures",
                forState: .Normal
            )
            newCollectionButton.removeTarget(
                self,
                action: "newCollection",
                forControlEvents: .TouchUpInside
            )
            newCollectionButton.addTarget(
                self,
                action: "removePictures",
                forControlEvents: .TouchUpInside
            )
        }
    }
    
    func collectionView(
        collectionView: UICollectionView,
        didDeselectItemAtIndexPath indexPath: NSIndexPath
    )
    {
        let cell = collectionView.cellForItemAtIndexPath( indexPath ) as! PhotoAlbumImageCell
        
        cell.alpha = 1.0
        
        if collectionView.indexPathsForSelectedItems().count == 0
        {
            newCollectionButton.setTitle(
                "New Collection",
                forState: .Normal
            )
            newCollectionButton.removeTarget(
                self,
                action: "removePictures",
                forControlEvents: .TouchUpInside
            )
            newCollectionButton.addTarget(
                self,
                action: "newCollection",
                forControlEvents: .TouchUpInside
            )
        }
    }
    
    func newCollection()
    {
        println( "Getting a new collection..." )
        
        // construct the query
        let newCollectionQuery = flickrQuery
        
        // create the URL
        let newCollectionURL = NSURL( string: newCollectionQuery )!
        
        // create and resume the task
        let newCollectionTask = NSURLSession.sharedSession().dataTaskWithURL( newCollectionURL )
        {
            newCollectionData, newCollectionResponse, newCollectionError in
            
            if newCollectionError != nil
            {
                println( "There was an error requesting a new collection from Flickr: \( newCollectionError )" )
            }
            else
            {
                var jsonificationError: NSErrorPointer = nil
                if let newCollectionResults = NSJSONSerialization.JSONObjectWithData(
                    newCollectionData,
                    options: nil,
                    error: jsonificationError
                ) as? [ String : AnyObject ]
                {
                    let newCollectionPhotos = newCollectionResults[ "photos" ] as! [ String : AnyObject ]
                    let newCollectionAlbumPossibles = newCollectionPhotos[ "photo" ] as! [ [ String : AnyObject ] ]
                    
                    var newAlbumMax = ( newCollectionAlbumPossibles.count > 30 ) ? 30 : newCollectionAlbumPossibles.count
                    
                    var photosToSelect = [ Int ]( count: newAlbumMax, repeatedValue: 0 )
                    for newAlbumCounter in 0...newAlbumMax-1
                    {
                        var randoPhoto: Int
                        do
                        {
                            randoPhoto = Int( arc4random_uniform( UInt32( newCollectionAlbumPossibles.count ) ) ) + 1
                        }
                        while contains( photosToSelect, randoPhoto )
                        
                        photosToSelect[ newAlbumCounter ] = randoPhoto
                    }
                    
                    // var photoURLs: [ NSURL ] = []
                    self.currentPhotoAlbum = [ Photo ]( count: newAlbumMax-1, repeatedValue: Photo() )
                    for randoURLCounter in 0...newAlbumMax-1
                    {
                        let currentRando = photosToSelect[ randoURLCounter ]
                        let currentPhoto = newCollectionAlbumPossibles[ currentRando ] as [ String : AnyObject ]
                        
                        let farmID = currentPhoto[ "farm" ] as! Int
                        let serverID = currentPhoto[ "server" ] as! String
                        let photoID = currentPhoto[ "id" ] as! String
                        let secret = currentPhoto[ "secret" ] as! String
                        
                        var photoInfo: [ String : AnyObject ] = [ : ]
                        photoInfo.updateValue( farmID, forKey: "farmID" )
                        photoInfo.updateValue( serverID, forKey: "serverID" )
                        photoInfo.updateValue( photoID, forKey: "photoID" )
                        photoInfo.updateValue( secret, forKey: "secret" )
                        
                        let newPhoto = Photo(
                            photoDictionary: photoInfo,
                            destinationPin: self.destination,
                            context: self.sharedContext
                        )
                        
//                        let photoURLString = "https://farm\( farmID! ).staticflickr.com/\( serverID! )/\( photoID! )_\( secret! ).jpg"
//                        let photoURL = NSURL( string: photoURLString )!
//                        photoURLs.append( photoURL )
                        self.currentPhotoAlbum[ randoURLCounter ] = newPhoto
                    }
                    
                    
                    self.maxAlbumPhotos = self.currentPhotoAlbum.count
                    var currentURLCounter = 0
                    for currentPhoto in self.currentPhotoAlbum
                    {
                        if let currentURL = currentPhoto.photoURL
                        {
                            dispatch_async( dispatch_get_main_queue() )
                            {
                                let photoTask = NSURLSession.sharedSession().dataTaskWithURL( currentURL )
                                {
                                    photoData, photoResponse, photoError in
                                    
                                    if photoError != nil
                                    {
                                        println( "There was an error getting the image from Flickr: \( photoError )." )
                                    }
                                    else
                                    {
                                        currentPhoto.albumImage = UIImage( data: photoData )
                                        self.currentPhotoAlbum[ currentURLCounter ] = currentPhoto
                                        // self.currentPhotoAlbum[ currentURLCounter ] = UIImage( data: photoData )
                                    }
                                    
                                    currentURLCounter++
                                }
                                photoTask.resume()
                                CoreDataStackManager.sharedInstance().saveContext()
                                // self.destinationImagesCollection.reloadData()
                            }
                        }
                    }
                }
                else
                {
                    println( "There was a problem parsing the new collection." )
                }
            }
        }
        newCollectionTask.resume()
        
        destination.photoCollection = currentPhotoAlbum
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func removePictures()
    {
        maxAlbumPhotos -= destinationImagesCollection.indexPathsForSelectedItems().count
        
        destinationImagesCollection.deleteItemsAtIndexPaths(
            destinationImagesCollection.indexPathsForSelectedItems() as! [ NSIndexPath ]
        )
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        newCollectionButton.setTitle(
            "New Collection",
            forState: .Normal
        )
        newCollectionButton.removeTarget(
            self,
            action: "removePictures",
            forControlEvents: .TouchUpInside
        )
        newCollectionButton.addTarget(
            self,
            action: "newCollection",
            forControlEvents: .TouchUpInside
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
