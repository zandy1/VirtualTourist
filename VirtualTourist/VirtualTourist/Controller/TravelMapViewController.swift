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

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap))
            gestureRecognizer.delegate = self
            mapView.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    /*
     func drawMap() {
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        for i in 0..<OnTheMapModel.studentInformation.count

        {
                    let lat = CLLocationDegrees(OnTheMapModel.studentInformation[i].latitude as! Double)
                    let long = CLLocationDegrees(OnTheMapModel.studentInformation[i].longitude as! Double)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = OnTheMapModel.studentInformation[i].firstName as! String
                    let last = OnTheMapModel.studentInformation[i].lastName as! String
                    let mediaURL = OnTheMapModel.studentInformation[i].mediaURL as! String
        
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
                // When the array is complete, we add the annotations to the map.
                self.mapView.addAnnotations(annotations)
                
        }
    */
    
    /*
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
             pinView!.pinColor = .red
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
             let app = UIApplication.shared
             if let toOpen = view.annotation?.subtitle! {
                 app.openURL(URL(string: toOpen)!)
             }
         }
     }
 //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
 //
 //        if control == annotationView.rightCalloutAccessoryView {
 //            let app = UIApplication.sharedApplication()
 //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
 //        }
 //    }

     */


}

