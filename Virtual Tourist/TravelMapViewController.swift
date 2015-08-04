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

class TravelMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var sharedContext: NSManagedObjectContext =
    {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    // var droppedPins: [ Int16 : Pin ] = [ Int16 : Pin ]()
    // var currentPins: [ MKPinAnnotationView : Int16 ] = [ MKPinAnnotationView : Int16 ]()
    // var totalPins: Int16 = 1
    var didJustLoad: Bool = true
    var inEditMode: Bool = false
    
//    func fetchAllPins() -> [ Pin ]
//    {
//        println( "fetching all pins..." )
//        let fetchError: NSErrorPointer = nil
//        
//        let pinsFetchRequest = NSFetchRequest( entityName: "Pin" )
//        
//        let pins: [ AnyObject ] = sharedContext.executeFetchRequest( pinsFetchRequest, error: fetchError )!
//        println( "pins.count: \( pins.count )" )
//        
//        if fetchError != nil
//        {
//            println( "There was an error fetching the pins from Core Data: \( fetchError )." )
//        }
//        
//        if !pins.isEmpty
//        {
//            let lastPin: Pin! = pins.last! as? Pin
//            totalPins = lastPin.pinNumber
//        }
//        
//        println( totalPins )
//        return pins as! [ Pin ]
//    }
    
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
        
//        var allPins: [ Pin ] = Pin.fetchAllPins()
//        if !allPins.isEmpty
//        {
//            droppedPins = createPinDictionary( &allPins )
//            currentPins = updateCurrentPins( &droppedPins )
//            println( "currentPins: \( currentPins )" )
//            addAllPins()
//        }
//        else
//        {
//            println( "allPins is empty." )
//        }
        
        Pin.fetchAllPins()
        addAllPins()
        
        let pinDropper = UILongPressGestureRecognizer( target: self, action: "dropPin" )
        self.view.addGestureRecognizer( pinDropper )
        
        mapView.delegate = self
        
        if let mapInfo: [ String : CLLocationDegrees ] = NSUserDefaults.standardUserDefaults().dictionaryForKey( "mapInfo" ) as? [ String : CLLocationDegrees ]
        {
            let centerLatitude = mapInfo[ "centerLatitude" ]
            let centerLongitude = mapInfo[ "centerLongitude" ]
            let spanLatDelta = mapInfo[ "spanLatitudeDelta" ]
            let spanLongDelta = mapInfo[ "spanLongitudeDelta" ]
            
            mapView.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: mapInfo[ "centerLatitude" ]!,
                    longitude: mapInfo[ "centerLongitude" ]!
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: ( mapInfo[ "spanLatitudeDelta" ]! ),
                    longitudeDelta: ( mapInfo[ "spanLongitudeDelta" ]! )
                )
            )
        }
        else
        {
            println( "Couldn't get the map info..." )
        }
    }
    
//    func createPinDictionary( inout pins: [ Pin ] ) -> [ Int16 : Pin ]
//    {
//        var newPinDictionary: [ Int16 : Pin ] = [ Int16 : Pin ]()
//        
//        for pin in pins
//        {
//            newPinDictionary.updateValue( pin, forKey: pin.pinNumber )
//        }
//        
//        return newPinDictionary
//    }
//    
//    func updateCurrentPins( inout pins: [ Int16 : Pin ] ) -> [ MKPinAnnotationView : Int16 ]
//    {
//        var newPinDictionary: [ MKPinAnnotationView : Int16 ] = [ MKPinAnnotationView : Int16 ]()
//        
//        for ( pinNumber, pin ) in pins
//        {
//            println( "pinNumber: \( pinNumber ), pin: \( pin )" )
//            newPinDictionary.updateValue( pinNumber, forKey: pin.mapPin )
//            totalPins++
//        }
//        
//        return newPinDictionary
//    }
    
    func addAllPins()
    {
        println( "adding all pins..." )
        for ( pinNumber, pin ) in Pin.droppedPins
        {
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = CLLocationCoordinate2D(
                latitude: pin.pinLatitude,
                longitude: pin.pinLongitude
            )
            newAnnotation.title = "\( pinNumber )"
            
            mapView.addAnnotation( newAnnotation )
            
//            println( "pinNumber: \( pinNumber ), pin: \( pin )" )
//            
//            // let currentPin = Pin.droppedPins[ pinNumber ]
//            
//            let currentPinAnnotationView = pin.mapPin
//            println( "currentPinAnnotationView: \( currentPinAnnotationView )" )
//            let currentAnnotation = pin.mapPin.annotation
//            println( "currentAnnotation: \( currentAnnotation )" )
//            
//            // mapView.addAnnotation( currentAnnotation )
//            mapView.addAnnotation( pin.mapPin.annotation )
        }
    }
    
    func dropPin()
    {
        if inEditMode
        {
            return
        }
        
        let recognizer = view.gestureRecognizers!.first as! UILongPressGestureRecognizer
//        let mapCoordinate = mapView.convertPoint(
//            recognizer.locationInView( self.view ),
//            toCoordinateFromView: self.view
//        )
//        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = mapCoordinate
        
        // TODO: change the way pins are removed from the map to use the droppedPins dict, not the title property
        // annotation.title = "\( Pin.totalPins )"
        
//        let mapPin = MKPinAnnotationView(
//            annotation: annotation,
//            reuseIdentifier: "mapPin"
//        )
        
        switch recognizer.state
        {
            case .Began:
                println( "Began long press..." )
                println( "at \( recognizer.locationInView( self.view ) )")
                let mapCoordinate = mapView.convertPoint(
                    recognizer.locationInView( self.view ),
                    toCoordinateFromView: self.view
                )
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapCoordinate
                let mapPin = MKPinAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: "mapPin"
                )
                mapView.addAnnotation( annotation )
                // currentPins.updateValue( totalPins, forKey: mapPin )
                let newPin = Pin(
                    location: mapCoordinate,
                    pin: mapPin,
                    context: sharedContext
                )
                
                // droppedPins.updateValue( newPin, forKey: totalPins )
                // totalPins++
                
                CoreDataStackManager.sharedInstance().saveContext()
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
            // println( "view: \( view ), title: \( view.annotation.title )" )
            let annotationToRemove = view as! MKPinAnnotationView
            println( "annotationToRemove: \( annotationToRemove )" )
            
            let pinNumber = Int16( view.annotation.title!.toInt()! )
            println( "pinNumber: \( pinNumber )" )
            let pinToRemove: Pin = Pin.droppedPins[ pinNumber ]!
            println( "pinToRemove: \( pinToRemove )" )
            
            Pin.currentPins.removeValueForKey( annotationToRemove )
            sharedContext.deleteObject( pinToRemove )
            mapView.removeAnnotation( annotationToRemove.annotation )
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        if didJustLoad
        {
            if let mapInfo: [ String : CLLocationDegrees ] = NSUserDefaults.standardUserDefaults().dictionaryForKey( "mapInfo" ) as? [ String : CLLocationDegrees ]
            {
                mapView.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: mapInfo[ "centerLatitude" ]!,
                        longitude: mapInfo[ "centerLongitude" ]!
                    ),
                    span: MKCoordinateSpan(
                        latitudeDelta: ( mapInfo[ "spanLatitudeDelta" ]! ),
                        longitudeDelta: ( mapInfo[ "spanLongitudeDelta" ]! )
                    )
                )
            }
            else
            {
                println( "Couldn't get the map info..." )
            }
            
            didJustLoad = false
            
            return
        }
    }
    
    func mapView(
        mapView: MKMapView!,
        regionDidChangeAnimated animated: Bool
    )
    {
        // println( "regionDidChangeAnimated" )
        
        let mapRegionCenterLatitude: CLLocationDegrees = mapView.region.center.latitude
        let mapRegionCenterLongitude: CLLocationDegrees = mapView.region.center.longitude
        let mapRegionSpanLatitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
        let mapRegionSpanLongitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta
        
        // println( "map span: \( mapView.region.span.latitudeDelta ), \( mapView.region.span.longitudeDelta )" )
        
        var mapDictionary: [ String : CLLocationDegrees ] = [ String : CLLocationDegrees ]()
        mapDictionary.updateValue( mapRegionCenterLatitude, forKey: "centerLatitude" )
        mapDictionary.updateValue( mapRegionCenterLongitude, forKey: "centerLongitude" )
        mapDictionary.updateValue( mapRegionSpanLatitudeDelta, forKey: "spanLatitudeDelta" )
        mapDictionary.updateValue( mapRegionSpanLongitudeDelta, forKey: "spanLongitudeDelta" )
        
        NSUserDefaults.standardUserDefaults().setObject( mapDictionary, forKey: "mapInfo" )
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
