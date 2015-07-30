//
//  TravelMapViewController.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 7/29/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var dropCoordinate: CLLocationCoordinate2D!
    
    @IBAction func editPins( sender: UIBarButtonItem )
    {
        mapView.frame.origin.y -= 75.0
        
        editPinsButton.title = "Done"
        editPinsButton.action = "dropMap:"
    }
    
    func dropMap( sender: UIBarButtonItem )
    {
        mapView.frame.origin.y += 75.0
        
        editPinsButton.title = "Edit"
        editPinsButton.action = "editPins:"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let pinDropper = UILongPressGestureRecognizer(target: self, action: "dropPin")
        pinDropper.minimumPressDuration = 1.0
        self.view.addGestureRecognizer( pinDropper )
    }
    
    func dropPin()
    {
        println( "Pressing long..." )
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = dropCoordinate
        mapView.addAnnotation( annotation )
    }
    
    override func touchesBegan( touches: Set<NSObject>, withEvent event: UIEvent )
    {
        let touch = touches.first! as! UITouch
        println( "touch location: \( touch.locationInView( self.view ) )" )
        
        let mapCoordinate = mapView.convertPoint( touch.locationInView( self.view ), toCoordinateFromView: self.view )
        dropCoordinate = mapCoordinate
        println( "touch location in map: \( mapCoordinate.latitude ), \( mapCoordinate.longitude )" )
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
