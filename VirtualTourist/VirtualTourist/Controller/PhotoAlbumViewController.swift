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
        let sortDescriptor = NSSortDescriptor(key: "image", ascending: false)
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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
          self.myNavigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(dummy))
          toDoWhenInView()
          mapView.delegate = self
          collectionView.dataSource = self
          collectionView.delegate = self
          collectionView.allowsSelection = true
          collectionView.allowsMultipleSelection = false
        
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
          if (pin.photo?.count == 0) {
              print("Pin Contains No Photos")
              disableNewCollectionButton(isDisabled: true)
              getFlickrImages(page: 1)
              collectionView.reloadData()
          }
          else {
            restoreFlickrParams()
            collectionView.reloadData()
            disableNewCollectionButton(isDisabled: true)
          }
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
    
    @objc func dummy() {
        
    }
    
    func toDoWhenInView() {
           //self.collectionView.reloadData()
           self.navigationController?.navigationBar.isHidden = false
    }
    
    func getFlickrImages(page: Int) {
        disableNewCollectionButton(isDisabled: true)
        FlickrAPI.searchPhotos(latitude: pin.latitude, longitude: pin.longitude, page: page, completion: self.handleGetFlickrImages(response:error:))
    }
    
    func handleGetData(data: Data?, response: URLResponse?, error: Error?) -> Data?{
        //let photo = Photo(context: dataController.viewContext)
        if (error == nil) {
           return(data)
        }
        else {
          return(nil)
        }
    }
    
    func handleGetFlickrImages(response: photosSearchResponse?, error: Error?) {
           if (response != nil) {
             currentPage = response!.photos.page
             numPages = response!.photos.pages
             imagesPerPage = response!.photos.perpage
             imagesAvailable = Int(response!.photos.total)
             saveFlickrParams()
             if (imagesAvailable > 0) {
                for image in response!.photos.photo {
                    let photo = Photo(context: dataController.viewContext)
                    photo.url = image.computeURL()
                    photo.image = nil
                    photo.pin = self.pin
                    try? dataController.viewContext.save()
                    //collectionView.reloadData()
                }
                //collectionView.reloadData()
             }
             else {
                noImagesFound()
             }
           }
           else {
              showFailure(failureType: "Unable To Get Images From Flickr", message: error?.localizedDescription ?? "")
           }
         }
    
    @IBAction func newCollectionTapped(_ sender: UIButton) {
        for photos in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photos)
        }
        try? self.dataController.viewContext.save()
        let randPage = Int.random(in: 1..<(numPages+1))
        getFlickrImages(page: randPage)
    }
    
    func disableNewCollectionButton(isDisabled: Bool) {
        self.newCollectionButton.isHidden = isDisabled
    }
    
       
    // Deletes the `Photo` at the specified index path
    func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
    
    @objc func deleteCell() {
        if let cellToDelete = collectionView.indexPathsForSelectedItems {
            for index in cellToDelete {
                deletePhoto(at: index)
            }
            self.collectionView.reloadData()
        }
    }
    
    func showFailure(failureType: String, message: String) {
        let alertVC = UIAlertController(title: failureType, message: message, preferredStyle: .alert)
         alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         self.present(alertVC, animated:true)
    }
    
    func noImagesFound() {
        let alertVC = UIAlertController(title: "", message: "No Images Found For This Location", preferredStyle: .alert)
         alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         self.present(alertVC, animated:true)
    }
    
    // ToDo This doesn't work if there are multiple pins - need to add the params to the Photo entity instead of using UserDefaults
    func saveFlickrParams() {
        UserDefaults.standard.set(currentPage, forKey: "CurrentPage")
        UserDefaults.standard.set(numPages, forKey: "NumPages")
        UserDefaults.standard.set(imagesPerPage, forKey: "ImagesPerPage")
        UserDefaults.standard.set(imagesAvailable, forKey: "ImagesAvailable")
    }
    
    func restoreFlickrParams() {
        let currentPage = UserDefaults.standard.integer(forKey: "CurrentPage")
        let numPages = UserDefaults.standard.integer(forKey: "NumPages")
        let imagesPerPage = UserDefaults.standard.integer(forKey: "ImagesPerPage")
        let imagesAvailable = UserDefaults.standard.integer(forKey: "ImagesAvailable")
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

    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
                fatalError("No sections in fetchedResultsController")
            }
         let sectionInfo = sections[section]
        //return sectionInfo.numberOfObjects
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        if (aPhoto.image == nil) {
            print("Need To Download Image")
            self.disableNewCollectionButton(isDisabled: true)
            cell.spinner.startAnimating()
            let url = URL(string: aPhoto.url!)
            FlickrAPI.getData(from: url!) { data, response, error in
              if error != nil { // Handle error…
                  //completion(false,error)
              }
              else {
                DispatchQueue.main.async {
                aPhoto.image = data
                cell.photoAlbumImageView.image = UIImage(data: aPhoto.image!)
                try? self.dataController.viewContext.save()
                cell.spinner.stopAnimating()
                self.disableNewCollectionButton(isDisabled: false)
                }
              }
            }
        }
        else {
          cell.photoAlbumImageView.image = UIImage(data: aPhoto.image!)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.myNavigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .done, target: self, action: #selector(deleteCell))
        }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.myNavigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(dummy))
        }
    
}

extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            collectionView.reloadData()
        }
     
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
             switch type {
             case .insert:
                 collectionView.insertItems(at: [newIndexPath!])
                 break
             case .delete:
                collectionView.deleteItems(at: [indexPath!])
                 break
             case .update:
                collectionView.reloadData()
                break
             default:
                 break
             }
         }

         func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
             let indexSet = IndexSet(integer: sectionIndex)
             switch type {
             case .insert:
             collectionView.insertSections(indexSet)
             break
             case .delete:
             collectionView.deleteSections(indexSet)
             break
             case .update:
             collectionView.reloadData()
             break
             default:
                  break
             }
         }

}

