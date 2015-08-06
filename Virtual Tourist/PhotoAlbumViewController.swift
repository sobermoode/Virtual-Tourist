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
    var session: NSURLSession? = nil
    
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
        
        let sessionConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        // let session: NSURLSession = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let flickrTask = session!.dataTaskWithRequest( flickrRequest )
        {
            data, response, error in
            
            println( "starting flckr query..." )
            if let flickrError = error
            {
                println( "There was an error with the Flickr request." )
            }
            else
            {
                // println( "response: \( response )" )
                // println( "data: \( data )" )
                var jsonificationError: NSErrorPointer = nil
                if let results = NSJSONSerialization.JSONObjectWithData(
                    data,
                    options: nil,
                    error: jsonificationError
                ) as? NSDictionary
                {
                    // println( "results: \( results )" )
                    if let photos = results[ "photos" ] as? [ String : AnyObject ],
                        photoArray = photos[ "photo" ] as? [ [ String : AnyObject ] ]
                    {
                        // println( "photoArray: \( photoArray )" )
                        let firstPhoto = photoArray[ 0 ]
                        println( "firstPhoto: \( firstPhoto )" )
                        
//                        if let farmID = firstPhoto[ "farm" ] as? Int
//                        {
//                            println( "farmID: \( farmID )" )
//                        }
//                        if let serverID = firstPhoto[ "server" ] as? String
//                        {
//                            println( "serverID: \( serverID )" )
//                        }
//                        if let photoID = firstPhoto[ "id" ] as? String
//                        {
//                            println( "photoID: \( photoID )" )
//                        }
//                        if let secret = firstPhoto[ "secret" ] as? String
//                        {
//                            println( "secret: \( secret )" )
//                        }
                        
                        let farmID = firstPhoto[ "farm" ] as? Int
                        let serverID = firstPhoto[ "server" ] as? String
                        let photoID = firstPhoto[ "id" ] as? String
                        let secret = firstPhoto[ "secret" ] as? String
                        
                        let photoURLString = "https://farm\( farmID! ).staticflickr.com/\( serverID! )/\( photoID! )_\( secret! ).jpg"
                        println( "photoURLString: \( photoURLString )" )
                        let photoURL = NSURL( string: photoURLString )!
                        // let photoRequest = NSURLRequest( URL: photoURL )
                        
                        dispatch_async( dispatch_get_main_queue() )
                        {
                            let photoTask = self.session!.dataTaskWithURL( photoURL )
                            {
                                photoData, photoResponse, photoError in
                                
                                println( "starting photo download..." )
                                if photoError != nil
                                {
                                    println( "There was an error getting the image from Flickr." )
                                }
                                else
                                {
                                    // println( "photoResponse: \( photoResponse )" )
                                    // println( "photoData: \( photoData )" )
                                    self.retrievedImage = UIImage( data: photoData )
                                }
                            }
                            photoTask.resume()
                            // println( "self.session.delegate: \( self.session!.delegate )" )
                            /*
                            let photoTask = session.dataTaskWithRequest( photoRequest )
                            {
                                photoData, photoResponse, photoError in
                                
                                if photoError != nil
                                {
                                    println( "There was an error getting the image from Flickr." )
                                }
                                else
                                {
                                    // println( "photoResponse: \( photoResponse )" )
                                    // println( "photoData: \( photoData )" )
                                    self.retrievedImage = UIImage( data: photoData )
                                }
                            }
                            photoTask.resume()
                            */
                            /*
                            let photoTask = session.downloadTaskWithURL( photoURL )
                            {
                                downloadURL, downloadResponse, downloadError in
                                
                                if downloadError != nil
                                {
                                    println( "There was an error downloading the image." )
                                }
                                else
                                {
                                    println( "downloadResponse: \( downloadResponse )" )
                                    println( "downloadURL: \( downloadURL )" )
                                    let imageData = NSData( contentsOfURL: downloadURL )!
                                    self.retrievedImage = UIImage( data: imageData )
                                }
                            }
                            photoTask.resume()
                            */
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
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        println( "task: \( task ) completed." )
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        println( "Did receive data..." )
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        println( "Did receive response..." )
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
        
        println( "collection view width: \( collectionView.frame.size.width )" )
        
        // cell.frame.size.width = ( collectionView.frame.size.width / 3 ) - 10
        cell.frame.size.width = ( collectionView.collectionViewLayout.collectionViewContentSize().width / 3 ) - 10
        cell.frame.size.height = cell.frame.size.width
        
        if retrievedImage != nil
        {
            // cell.destinationImage.frame.size = cell.frame.size
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
