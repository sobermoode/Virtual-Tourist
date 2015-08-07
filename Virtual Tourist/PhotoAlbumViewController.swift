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
    
    let flickrQuery = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=71549104e5500eb7d194d040cc55ea10&lat=33.862237&lon=-118.399519&format=json&nojsoncallback=1"
    var retrievedImage: UIImage? = nil
    
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
        
        destinationImagesCollection.dataSource = self
        destinationImagesCollection.delegate = self
        
        let flickrURL = NSURL( string: flickrQuery )!
        let flickrRequest = NSURLRequest( URL: flickrURL )
        
        let flickrTask = NSURLSession.sharedSession().dataTaskWithRequest( flickrRequest )
        {
            flickrData, flickrResponse, flickrError in
            
            println( "starting flckr query..." )
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
                    if let photos = results[ "photos" ] as? [ String : AnyObject ],
                        photoArray = photos[ "photo" ] as? [ [ String : AnyObject ] ]
                    {
                        let firstPhoto = photoArray[ 0 ]
                        let farmID = firstPhoto[ "farm" ] as? Int
                        let serverID = firstPhoto[ "server" ] as? String
                        let photoID = firstPhoto[ "id" ] as? String
                        let secret = firstPhoto[ "secret" ] as? String
                        
                        let photoURLString = "https://farm\( farmID! ).staticflickr.com/\( serverID! )/\( photoID! )_\( secret! ).jpg"
                        let photoURL = NSURL( string: photoURLString )!
                        
                        dispatch_async( dispatch_get_main_queue() )
                        {
                            let photoTask = NSURLSession.sharedSession().dataTaskWithURL( photoURL )
                            {
                                photoData, photoResponse, photoError in
                                
                                if photoError != nil
                                {
                                    println( "There was an error getting the image from Flickr: \( photoError )." )
                                }
                                else
                                {
                                    self.retrievedImage = UIImage( data: photoData )
                                }
                            }
                            photoTask.resume()
                        }
                    }
                    else
                    {
                        println( "There was a problem extracting the photos." )
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
        // TODO: change this to be a max of 21; if the location returns less than 21 images, return that amount.
        return 21
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
        
        if retrievedImage != nil
        {
            cell.destinationImage.contentMode = UIViewContentMode.ScaleAspectFill
            cell.destinationImage.image = retrievedImage!
        }
        
        return cell
    }
    
    func collectionView(
        collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath
    )
    {
        println( "Selected a cell..." )
        let cell = collectionView.cellForItemAtIndexPath( indexPath ) as! PhotoAlbumImageCell
        
        if cell.backgroundColor == UIColor.redColor()
        {
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        else
        {
            cell.backgroundColor = UIColor.redColor()
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
