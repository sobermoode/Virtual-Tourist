//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 8/4/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var destinationMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var destinationImagesCollection: UICollectionView!
    
    var destination: CLLocationCoordinate2D!
    var maxAlbumPhotos: Int = 30
    
    let flickrQuery = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=71549104e5500eb7d194d040cc55ea10&lat=33.862237&lon=-118.399519&format=json&nojsoncallback=1"
    var flickrResultsPages: Int = 0
    var flickrResultsPerPage: Int = 0
    var flickrResultsPhotos: [ [ String : AnyObject ] ] = []
    var currentPhotoAlbum: [ UIImage? ] = []
    
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
            center: destination,
            span: MKCoordinateSpan(
                latitudeDelta: 0.1,
                longitudeDelta: 0.1
            )
        )
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destination
        
        destinationMap.addAnnotation( destinationAnnotation )
        
        destinationImagesCollection.allowsMultipleSelection = true
        destinationImagesCollection.dataSource = self
        destinationImagesCollection.delegate = self
        
        newCollectionButton.addTarget(
            self,
            action: "newCollection",
            forControlEvents: .TouchUpInside
        )
        
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
                    
                    // set the initial photo album to the first 30 images (or max that was returned if less)
                    // for every subsequent request for a new collection, test for ( remainingInPage - 30 > 0 )
                    // and if not, that ( remainingPages > 0 ), and get the next 30 photos or the first 30 from
                    // the next page. then update remainingInPage and remainingPages.
                    var photoURLs: [ NSURL ] = []
                    var initialAlbumMax = ( self.flickrResultsPhotos.count > 30 ) ? 30 : self.flickrResultsPhotos.count
                    for initialAlbumCounter in 1...initialAlbumMax
                    {
                        let currentPhoto = self.flickrResultsPhotos[ initialAlbumCounter ] as [ String : AnyObject ]
                        
                        let farmID = currentPhoto[ "farm" ] as? Int
                        let serverID = currentPhoto[ "server" ] as? String
                        let photoID = currentPhoto[ "id" ] as? String
                        let secret = currentPhoto[ "secret" ] as? String
                        
                        let photoURLString = "https://farm\( farmID! ).staticflickr.com/\( serverID! )/\( photoID! )_\( secret! ).jpg"
                        let photoURL = NSURL( string: photoURLString )!
                        photoURLs.append( photoURL )
                    }
                    
                    self.currentPhotoAlbum = [ UIImage? ]( count: photoURLs.count, repeatedValue: nil )
                    var currentURLCounter = 0
                    for currentURL in photoURLs
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
                                    self.currentPhotoAlbum[ currentURLCounter ] = UIImage( data: photoData )
                                }
                                
                                currentURLCounter++
                            }
                            photoTask.resume()
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
        
        if currentPhotoAlbum[ indexPath.item ] != nil
        {
            cell.destinationImage.contentMode = UIViewContentMode.ScaleAspectFill
            cell.destinationImage.image = currentPhotoAlbum[ indexPath.item ]
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
    }
    
    func removePictures()
    {
        maxAlbumPhotos -= destinationImagesCollection.indexPathsForSelectedItems().count
        
        destinationImagesCollection.deleteItemsAtIndexPaths(
            destinationImagesCollection.indexPathsForSelectedItems() as! [ NSIndexPath ]
        )
        
        newCollectionButton.setTitle(
            "New Collection",
            forState: .Normal
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
