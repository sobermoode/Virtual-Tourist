//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 8/4/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var destinationMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var destinationImagesCollection: UICollectionView!
    
    var destination: CLLocationCoordinate2D!
    
    let flickrQuery = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=71549104e5500eb7d194d040cc55ea10&lat=33.862237&lon=-118.399519&format=json&nojsoncallback=1"
    
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
            data, response, error in
            
            if let flickrError = error
            {
                println( "There was an error with the Flickr request." )
            }
            else
            {
                // println( "response: \( response )" )
                // println( "data: \( data )" )
                var jsonificationError: NSErrorPointer = nil
                if let results = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: jsonificationError) as? NSDictionary
                {
                    println( "results: \( results )" )
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
