//
//  TravelMapViewController.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/26/21.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let dataController = DataController(modelName: "VirtualTourist")
    //var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    var day: Int!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.load()
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(handleTap))
            gestureRecognizer.delegate = self
            mapView.addGestureRecognizer(gestureRecognizer)
        //print(day)
        setupFetchedResultsController()
        // Do any additional setup after loading the view.
        if UserDefaults.standard.bool(forKey: "CenterSaved") {
            restoreView()
        }
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        addPin(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
    }
    
    /// Add Pin
    func addPin(latitude: Double, longitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        try? dataController.viewContext.save()
    }
    
    // Restore Center and Zoom Level
    func restoreView() {
        let lat = UserDefaults.standard.double(forKey: "CenterLatitude")
        let long = UserDefaults.standard.double(forKey: "CenterLongitude")
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let max = UserDefaults.standard.double(forKey: "CenterMax")
        let min = UserDefaults.standard.double(forKey: "CenterMin")
        mapView.setCenter(coordinate, animated: false)
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: min, maxCenterCoordinateDistance: max)
    }
    
    /*
     func drawMap() {
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        let count = fetchedResultsController.sections?[0].numberOfObjects ?? 0
        
        for i in 0..<count

        {
                    let aPin = fetchedResultsController.object(at: )
                    let lat = CLLocationDegrees(aPin.latitude)
                    let long = CLLocationDegrees(aPin.longitude)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
        
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
                // When the array is complete, we add the annotations to the map.
                self.mapView.addAnnotations(annotations)
                
        }
    */
    
    
     // MARK: - MKMapViewDelegate

     // Here we create a view with a "right callout accessory view". You might choose to look into other
     // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
     // method in TableViewDataSource.
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         
         let reuseId = "pin"
         
         var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

         if pinView == nil {
             pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
             pinView!.canShowCallout = true
             pinView!.pinTintColor = .red
             pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
         }
         else {
             pinView!.annotation = annotation
         }
         
         return pinView
     }

     
     // This delegate method is implemented to respond to taps. It opens the system browser
     // to the URL specified in the annotationViews subtitle property.
     func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
         if control == view.rightCalloutAccessoryView {
             print("Pin Tapped")
             //let app = UIApplication.shared
             //if let toOpen = view.annotation?.subtitle! {
                 //app.openURL(URL(string: toOpen)!)
             //}
         }
     }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!)
    {
        print("Pin Clicked")
    }

    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "CenterLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "CenterLongitude")
        UserDefaults.standard.set(mapView.cameraZoomRange.maxCenterCoordinateDistance, forKey: "CenterMax")
        UserDefaults.standard.set(mapView.cameraZoomRange.minCenterCoordinateDistance, forKey: "CenterMin")
        UserDefaults.standard.set(true, forKey: "CenterSaved")
        print("Region Changed")
    }
}

extension TravelMapViewController:NSFetchedResultsControllerDelegate {
    
}
