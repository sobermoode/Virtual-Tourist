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
    
    var droppedPins: [ Pin ] = []
    var inEditMode: Bool = false
    
    func fetchAllPins() -> [ Pin ]
    {
        let fetchError: NSErrorPointer = nil
        
        let pinsFetchRequest = NSFetchRequest( entityName: "Pin" )
        
        let pins = sharedContext.executeFetchRequest( pinsFetchRequest, error: fetchError )
        
        if fetchError != nil
        {
            println( "There was an error fetching the pins from Core Data: \( fetchError )." )
        }
        
        return pins as! [ Pin ]
    }
    
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
        
        droppedPins = fetchAllPins()
        if !droppedPins.isEmpty
        {
            addDroppedPins()
        }
        
        let pinDropper = UILongPressGestureRecognizer( target: self, action: "dropPin" )
        // pinDropper.minimumPressDuration = 1.0
        self.view.addGestureRecognizer( pinDropper )
        
        mapView.delegate = self
    }
    
    func addDroppedPins()
    {
        for pin in droppedPins
        {
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = CLLocationCoordinate2D(
                latitude: pin.pinLatitude,
                longitude: pin.pinLongitude
            )
            
            mapView.addAnnotation( newAnnotation )
        }
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
        
        // mapView.addAnnotation( annotation )
        
        /* TODO: use a dictionary to associate the new annotation with the Pin.
            this needs to happen because otherwise i cant delete Pins from the
            context, since the annotation view being used in the delegate
            function is using the MKPointAnnotation and not the Pin object.
        */
        let newPin = Pin(
            location: mapCoordinate,
            context: sharedContext
        )
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        switch recognizer.state
        {
            case .Began:
                println( "Began long press..." )
                mapView.addAnnotation( annotation )
                return
            
            case .Changed:
                println( "Press is changing..." )
                return
            
            case .Ended:
                println( "Ending long press..." )
                return
            
            default:
                return
        }
    }
    
    func mapView(
        mapView: MKMapView!,
        didSelectAnnotationView view: MKAnnotationView!
        )
    {
        if !inEditMode
        {
            // segue to photo album
        }
        else
        {
            // println( "didSelectAnnotationView" )
            let annotationToRemove = view.annotation
            mapView.removeAnnotation( annotationToRemove )
            
            sharedContext.deleteObject(<#object: NSManagedObject#>)
        }
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
