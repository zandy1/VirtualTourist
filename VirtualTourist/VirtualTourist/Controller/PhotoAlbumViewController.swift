//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Alexander Brown on 3/30/21.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //var memes = [Meme]()
    
    override func viewDidLoad() {
          super.viewDidLoad()
          toDoWhenInView()
          mapView.delegate = self
          collectionView.dataSource = self
          collectionView.delegate = self
          //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(editMeme))

          // Do any additional setup after loading the view.
          //display
          let space:CGFloat = 1.0
          let dimension = (view.frame.size.width - (2 * space)) / 3.0
          let height = dimension
          flowLayout.minimumInteritemSpacing = space
          flowLayout.minimumLineSpacing = space
          flowLayout.itemSize = CGSize(width: dimension, height: height)
    }
    
    func toDoWhenInView() {
           //memes = appDelegate.memes
           collectionView.reloadData()
           //self.navigationController?.navigationBar.isHidden = false
           //self.tabBarController?.tabBar.isHidden = false
       }

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

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print(memes.count)
        //return memes.count
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        //let meme = self.memes[indexPath.row]
        // image
        //cell.memeImageView.image = meme.memedImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
        }

    
}