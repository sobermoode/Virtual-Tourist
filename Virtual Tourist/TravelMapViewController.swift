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
    
    // var didJustLoad: Bool = true
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
        
        mapView.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 20,
                longitude: 20
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 10,
                longitudeDelta: 20
            )
        )
        
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
            
            /*
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
            */
            mapView.setCenterCoordinate(
                CLLocationCoordinate2D(
                    latitude: mapInfo[ "centerLatitude" ]!,
                    longitude: mapInfo[ "centerLongitude" ]!
                ),
                animated: true
            )
        }
        else
        {
            // mapView.region = MKCoordinateRegion()
            mapView.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 33.862237,
                    longitude: -118.399519
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 3.0,
                    longitudeDelta: 3.0
                )
            )
//            println( "Couldn't get the map info..." )
        }
        
//        Pin.fetchAllPins()
//        addAllPins()
//        
//        let pinDropper = UILongPressGestureRecognizer( target: self, action: "dropPin" )
//        self.view.addGestureRecognizer( pinDropper )
//        
//        mapView.delegate = self
    }
    
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
            newAnnotation.title = "\( pin.pinNumber )"
            
            mapView.addAnnotation( newAnnotation )
        }
    }
    
    func dropPin()
    {
        if inEditMode
        {
            return
        }
        
        let recognizer = view.gestureRecognizers!.first as! UILongPressGestureRecognizer
        
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
                mapPin.canShowCallout = false
                mapView.addAnnotation( annotation )
                // currentPins.updateValue( totalPins, forKey: mapPin )
                let newPin = Pin(
                    location: mapCoordinate,
                    pin: mapPin,
                    context: sharedContext
                )
                annotation.title = "\( newPin.pinNumber )"
                mapPin.canShowCallout = false
                
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
            let photoAlbum = storyboard?.instantiateViewControllerWithIdentifier( "PhotoAlbum2" ) as! PhotoAlbumViewController
            // photoAlbum.destination = view.annotation.coordinate
            let pinNumber = Int16( view.annotation.title!.toInt()! )
            let destinationPin: Pin = Pin.droppedPins[ pinNumber ]!
            photoAlbum.destination = destinationPin
//            if destinationPin.photoCollection.count != 0
//            {
//                photoAlbum.currentPhotoAlbum = destinationPin.photoCollection
//            }
            
            presentViewController(
                photoAlbum,
                animated: true,
                completion: nil
            )
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
            
            // Pin.currentPins.removeValueForKey( annotationToRemove )
            Pin.droppedPins.removeValueForKey( pinToRemove.pinNumber )
            sharedContext.deleteObject( pinToRemove )
            mapView.removeAnnotation( annotationToRemove.annotation )
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func mapView(
        mapView: MKMapView!,
        regionDidChangeAnimated animated: Bool
    )
    {
        println( "regionDidChangeAnimated" )
        
        let mapRegionCenterLatitude: CLLocationDegrees = mapView.region.center.latitude
        let mapRegionCenterLongitude: CLLocationDegrees = mapView.region.center.longitude
        let mapRegionSpanLatitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
        let mapRegionSpanLongitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta
        
        println( "map span: \( mapView.region.span.latitudeDelta ), \( mapView.region.span.longitudeDelta )" )
        
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
