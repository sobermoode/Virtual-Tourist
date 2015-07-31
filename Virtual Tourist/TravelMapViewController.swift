//
//  TravelMapViewController.swift
//  Virtual Tourist
//
//  Created by Aaron Justman on 7/29/15.
//  Copyright (c) 2015 AaronJ. All rights reserved.
//

import UIKit
import MapKit
import CoreData

/* TODO: BUG #1
    if you add a pin while the "tap pins to delete" label is active, the map will drop
    back down, but the button won't change back to "edit," so if you continue to click
    "done," the map will continue to get shifted -75 points and go offscreen.
*/

class TravelMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    // var dropCoordinate: CLLocationCoordinate2D!
    lazy var sharedContext: NSManagedObjectContext =
    {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    var inEditMode: Bool = false
    
    @IBAction func editPins( sender: UIBarButtonItem )
    {
        mapView.frame.origin.y -= 75.0
        
        editPinsButton.title = "Done"
        editPinsButton.action = "dropMap:"
        
        inEditMode = true
    }
    
    func dropMap( sender: UIBarButtonItem )
    {
        mapView.frame.origin.y += 75.0
        
        editPinsButton.title = "Edit"
        editPinsButton.action = "editPins:"
        
        inEditMode = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let pinDropper = UILongPressGestureRecognizer( target: self, action: "dropPin" )
        // pinDropper.minimumPressDuration = 1.0
        self.view.addGestureRecognizer( pinDropper )
    }
    
    func dropPin()
    {
        // println( "Pressing long..." )
        
        
        // annotation.coordinate = dropCoordinate
        let recognizer = view.gestureRecognizers!.first as! UILongPressGestureRecognizer
        let mapCoordinate = mapView.convertPoint(
            recognizer.locationInView( self.view ),
            toCoordinateFromView: self.view
        )
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCoordinate
        
//        let mapPin = MKPinAnnotationView(
//            annotation: annotation,
//            reuseIdentifier: "mapPin"
//        )
        
        mapView.addAnnotation( annotation )
        
        let newPin = Pin(
            location: mapCoordinate,
            context: sharedContext
        )
        
        CoreDataStackManager.sharedInstance().saveContext()
        
//        switch recognizer.state
//        {
//            case .Began:
//                println( "Began long press..." )
//                mapView.addAnnotation( annotation )
//                return
//            
//            case .Changed:
//                println( "Press is changing..." )
//                return
//            
//            case .Ended:
//                println( "Ending long press..." )
//                return
//            
//            default:
//                return
//        }
    }
    
//    override func touchesBegan( touches: Set<NSObject>, withEvent event: UIEvent )
//    {
//        let touch = touches.first! as! UITouch
//        println( "touch location: \( touch.locationInView( self.view ) )" )
//        
//        let mapCoordinate = mapView.convertPoint( touch.locationInView( self.view ), toCoordinateFromView: self.view )
//        dropCoordinate = mapCoordinate
//        println( "touch location in map: \( mapCoordinate.latitude ), \( mapCoordinate.longitude )" )
//    }

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
