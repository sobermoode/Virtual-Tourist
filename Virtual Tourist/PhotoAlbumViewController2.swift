//
//  PhotoAlbumViewController2.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 8/13/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController2: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var destinationMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var destinationImagesCollection: UICollectionView!
    
    var destination: Pin!
    var maxAlbumPhotos: Int = 30
    // var currentPhotoAlbum: [ Photo ]
    
    let flickrQuery = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=71549104e5500eb7d194d040cc55ea10&lat=33.862237&lon=-118.399519&format=json&nojsoncallback=1"
    
    lazy var sharedContext: NSManagedObjectContext =
    {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set up views
        setUpNavBar()
        setUpMap()
        
        // add action to the button
        newCollectionButton.addTarget(
            self,
            action: "newCollection",
            forControlEvents: .TouchUpInside
        )
        
        // set data source and delegate
        destinationImagesCollection.allowsMultipleSelection = true
        destinationImagesCollection.dataSource = self
        destinationImagesCollection.delegate = self
        
        // if the pin doesn't already have a photo collection, then get images from Flickr
        if destination.photoCollection.isEmpty
        {
            requestInitialPhotoAlbum()
        }
    }
    
    // MARK: Setup functions
    
    func setUpNavBar()
    {
        var navItem = UINavigationItem( title: "Photo Album" )
        
        let backButton = UIBarButtonItem(
            title: "Back to Map",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "backToMap:"
        )
        
        navItem.leftBarButtonItem = backButton
        
        navBar.items = [ navItem ]
    }
    
    func setUpMap()
    {
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
                    let photos = results[ "photos" ] as! [ [ String : AnyObject ] ]
                    
                    // create Photo objects from the Flickr results
                    for initialAlbumCounter in 0...self.maxAlbumPhotos - 1
                    {
                        let currentPhoto = photos[ initialAlbumCounter ] as [ String : AnyObject ]
                        let farmID = currentPhoto[ "farm" ] as! NSNumber
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
                        
                        self.destination.photoCollection.append( newPhoto )
                    }
                    
                    // use the Photo objects' URLs to get the images from Flickr
                    var currentURLCounter = 0
                    for currentPhoto in self.destination.photoCollection
                    {
                        let currentURL = currentPhoto.photoURL
                        
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
                                }
                                
                                currentURLCounter++
                            }
                            photoTask.resume()
                            
                            CoreDataStackManager.sharedInstance().saveContext()
                            self.destinationImagesCollection.reloadData()
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
    
    // return to the map
    func backToMap( sender: UIBarButtonItem )
    {
        dismissViewControllerAnimated(
            true,
            completion: nil
        )
    }
    
    // MARK: Collection View functions
    
    func collectionView(
        collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int
    {
        return destination.photoCollection.count
    }
    
    func collectionView(
        collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath
    ) -> UICollectionViewCell
    {
        // dequeue a cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "photoAlbumImageCell",
            forIndexPath: indexPath
        ) as! PhotoAlbumImageCell
        
        // set the cell dimensions
        cell.frame.size.width = ( collectionView.collectionViewLayout.collectionViewContentSize().width / 3 ) - 10
        cell.frame.size.height = cell.frame.size.width
        
        // make sure the Photo object finished getting an image from Flickr
        if let theAlbumImage = destination.photoCollection[ indexPath.item ].albumImage
        {
            cell.destinationImage.contentMode = UIViewContentMode.ScaleAspectFill
            cell.destinationImage.image = theAlbumImage
        }
        
        // restore the cell's selected state, if necessary
        cell.alpha = ( cell.selected ) ? 0.35 : 1.0
        
        return cell
    }
    
    func collectionView(
        collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath
    )
    {
        // get the cell that was selected
        let cell = collectionView.cellForItemAtIndexPath( indexPath ) as! PhotoAlbumImageCell
        
        // make the cell appear a lighter color
        cell.alpha = 0.35
        
        // set up the button to deal with the current state of the collection view;
        // if there are selected cells, the button removes them,
        // if there are no selected cells, the button requests a new set of images from Flickr
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
        // get the cell that was deselected
        let cell = collectionView.cellForItemAtIndexPath( indexPath ) as! PhotoAlbumImageCell
        
        // restore the cell's unselected look
        cell.alpha = 1.0
        
        // set up the button to deal with the current state of the collection view
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
