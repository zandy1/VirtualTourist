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
    
    var pins = [Pin]()
    
    var selectedPin: Pin!
    
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
        drawMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .began {
           return
        }
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        //mapView.addAnnotation(annotation)
        addPin(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
    }
    
    /// Add Pin
    func addPin(latitude: Double, longitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        try? dataController.viewContext.save()
        drawMap()
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
    

    func drawMap() {
        var annotations = [MKPointAnnotation]()
     
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let fetchedResults = try? dataController.viewContext.fetch(fetchRequest)
            self.pins = fetchedResults!
            for item in fetchedResults! {
                
                let lat = CLLocationDegrees(item.latitude)
                let long = CLLocationDegrees(item.longitude)
                //print(lat, long)
                     
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                     
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
                }
            self.mapView.addAnnotations(annotations)
            } catch let error as NSError {
                // something went wrong, print the error.
                print(error.description)
              }
        }
    
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        let coordinate = view.annotation?.coordinate
        let lat = coordinate?.latitude
        let long = coordinate?.longitude
        for pin in self.pins {
            if pin.latitude == lat && pin.longitude == long {
             selectedPin = pin
             //print(selectedPin.latitude, selectedPin.longitude)
            }
        }
        self.performSegue(withIdentifier: "photoAlbum", sender: nil)
    }
    
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "CenterLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "CenterLongitude")
        UserDefaults.standard.set(mapView.cameraZoomRange.maxCenterCoordinateDistance, forKey: "CenterMax")
        UserDefaults.standard.set(mapView.cameraZoomRange.minCenterCoordinateDistance, forKey: "CenterMin")
        UserDefaults.standard.set(true, forKey: "CenterSaved")
    }
    
    // Remove Old Pins
    func clear_pins() {
      for _annotation in self.mapView.annotations {
         self.mapView.removeAnnotation(_annotation)
      }
    }
        
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // If this is a PhotoAlbumViewController, we'll configure its `Pin`
         if let vc = segue.destination as? PhotoAlbumViewController {
             vc.pin = selectedPin
             vc.dataController = dataController
         }
     }
     
}

extension TravelMapViewController:NSFetchedResultsControllerDelegate {
    
}
