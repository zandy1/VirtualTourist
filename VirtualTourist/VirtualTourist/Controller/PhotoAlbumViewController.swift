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
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    @IBOutlet var newCollectionButton: UIButton!
    
    var pin: Pin!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    var currentPage: Int!
    var numPages: Int!
    var imagesPerPage: Int!
    var imagesAvailable: Int!

    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "image", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
          super.viewDidLoad()
          self.myNavigationItem.leftBarButtonItem = UIBarButtonItem(title: "< OK", style: .done, target: self, action: #selector(ok))
          toDoWhenInView()
          mapView.delegate = self
          collectionView.dataSource = self
          collectionView.delegate = self

          // Do any additional setup after loading the view.
          //display
          let space:CGFloat = 1.0
          let dimension = (view.frame.size.width - (2 * space)) / 3.0
          let height = dimension
          flowLayout.minimumInteritemSpacing = space
          flowLayout.minimumLineSpacing = space
          flowLayout.itemSize = CGSize(width: dimension, height: height)
          setupFetchedResultsController()
          drawMap()
          toDoWhenInView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc func ok() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func toDoWhenInView() {
           //memes = appDelegate.memes
           collectionView.reloadData()
           self.navigationController?.navigationBar.isHidden = false
    }
    
    func downloadImages() {
        disableNewCollectionButton(isDisabled: true)
    }
    
    
    func getFlickrImages(page: Int) {
        FlickrAPI.searchPhotos(latitude: pin.latitude, longitude: pin.longitude, page: page, completion: self.handleGetFlickrImages(response:error:))
    }
     
    func handleGetFlickrImages(response: photosSearchResponse?, error: Error?) {
       if (response != nil) {
         currentPage = response!.photos.page
         numPages = response!.photos.pages
         imagesPerPage = Int(response!.photos.perpage)
         imagesAvailable = Int(response!.photos.total)
         if (imagesAvailable > 0) {
            for image in response!.photo {
                //addPhoto(urlString: image.computeURL())
            }
         }
       }
       else {
          showFailure(failureType: "Unable To Get Images From Flickr", message: error?.localizedDescription ?? "")
       }
     }
    
    
    @IBAction func newCollectionTapped(_ sender: UIButton) {
    
       }
    
    func disableNewCollectionButton(isDisabled: Bool) {
        self.newCollectionButton.isHidden = isDisabled
    }
    
    // Adds a new `Photo` to the end of the `pin`'s `photos` array
    func addPhoto(urlString: String) {
        let photo = Photo(context: dataController.viewContext)
        if let url = URL(string: urlString) {
           let imgData = NSData(contentsOf: url)
           photo.image = Data(imgData!)
           photo.pin = pin
           try? dataController.viewContext.save()
        }
    }

    // Deletes the `Photo` at the specified index path
    func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
    
    func showFailure(failureType: String, message: String) {
        let alertVC = UIAlertController(title: failureType, message: message, preferredStyle: .alert)
         alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         self.present(alertVC, animated:true)
    }

    func drawMap() {
                
      // We will create an MKPointAnnotation for each dictionary in "locations". The
      // point annotations will be stored in this array, and then provided to the map view.
      var annotations = [MKPointAnnotation]()
                
      // Here we create the annotation and set its coordiate, title, and subtitle properties
      let annotation = MKPointAnnotation()
        
      let lat = CLLocationDegrees(pin.latitude)
      let long = CLLocationDegrees(pin.longitude)
      //print(lat)
      //print(long)
    
       // The lat and long are used to create a CLLocationCoordinates2D instance.
       let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
      
       annotation.coordinate = coordinate
                            
       // Finally we place the annotation in an array of annotations.
       annotations.append(annotation)
                        
       // We add the annotations to the map.
       self.mapView.addAnnotations(annotations)
        
       // Zoom Region
        self.mapView.setRegion(MKCoordinateRegion(center:annotation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000), animated:true)
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

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        // image
        cell.photoAlbumImageView.image = UIImage(data: aPhoto.image!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
        }

    
}

extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    
}
