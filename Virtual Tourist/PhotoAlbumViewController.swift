//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 8/4/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var destinationMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var destinationImagesCollection: UICollectionView!
    
    var destination: CLLocationCoordinate2D!
    
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
    }
    
    func backToMap( sender: UIBarButtonItem )
    {
        dismissViewControllerAnimated(
            true,
            completion: nil
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
