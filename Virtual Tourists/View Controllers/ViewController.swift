//
//  ViewController.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/3/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    let networkController = NetworkController.shared
    var annotation: MKPointAnnotation? {
        didSet {
            print("annotation was hit in the view controller")
            populateCollectionView()
            self.collectionView.reloadData()
        }
    }
    
    var pin: Pin? {
        didSet {
            print("pin was hit in the view controller")
            loadViewIfNeeded()
            setAnnotationFromPin()
        }
    }
    
    var coreDataPhotoImages: [UIImage]? {
        didSet {
            print("core data photo images array was hit")
        }
    }
    
    var imagesToPopulateCollectionView: [UIImage]{
        return pin?.photos?.count == 0 ?  networkController.photoImagesOfCurrentNetworkCall : coreDataPhotoImages ?? []
    }
    
    //if we pass a pin in, then we don't call a fetch function it should already have photos in it
    //if this is a new pin, then we have to call the fetch function with the passed in locations.
    
    func setAnnotationFromPin(){
        guard let passedInPin = self.pin else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        
        let coordinates = CLLocationCoordinate2D(latitude: passedInPin.lat, longitude: passedInPin.lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapView.region = region
        self.annotation = annotation
        mapView.addAnnotation(annotation)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource  = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveOnBackgroundQueue()
    }
    
    func saveOnBackgroundQueue(){
        //create a queue
        let queue = DispatchQueue(label: "save")
        queue.async {
            print("inside the sync queue")
            self.savePhotosToPin()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        networkController.photoImagesOfCurrentNetworkCall.removeAll()
    }
    
    func populateCollectionView(){
        guard let passedInPin = self.pin, let photos = passedInPin.photos else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        if photos.count == 0 {
            print("pin has no photos so we are making network call based on pin's lat and lon")
            networkCall(lat: passedInPin.lat, lon: passedInPin.lon)
        } else {
            print("passed in pin does have photos")
            self.coreDataPhotoImages =  PinController.shared.getImageDataFromPhoto(pin: passedInPin)
            print("coreDataPhotoImages.count:  \(String(describing: self.coreDataPhotoImages?.count))")
        }
    }
    
    //calling this function freezes the UI
    func savePhotosToPin(){
        guard let passedInPin = self.pin else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        
        print("photos.count: \(passedInPin.photos?.count)")
        if passedInPin.photos?.count == 0 {
            print("creating newPhotos")
            convertImageToDataFor(pin: passedInPin)
        } else {
            print("passedInPin already has photos so no need to save")
        }
    }
    
    func convertImageToDataFor(pin: Pin) {
        for image in networkController.photoImagesOfCurrentNetworkCall {
            if let imageData = image.pngData() {
               PhotoController.createPhoto(withImageData: imageData, andWithPin: pin)
            } else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            }
        }
        print("function: \(#function)")
    }
    
    func networkCall(lat: Double, lon: Double){
        NetworkController.shared.fetchPhotoInformationAtGeoLocation(lat: lat, lon: lon) { (photoInformationArray, error) in
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                return
            }
            guard let returnedArray = photoInformationArray else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return
            }
            
            NetworkController.shared.fetchPhotos(withPhotoInformation: returnedArray) { (error) in
                if let error = error {
                    print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                    return
                }
                self.collectionView.reloadData()
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return networkController.photoImagesOfCurrentNetworkCall.count
        return imagesToPopulateCollectionView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
//        let photo = networkController.photoImagesOfCurrentNetworkCall[indexPath.item]
        let photo = imagesToPopulateCollectionView[indexPath.row]
        cell.photoImageView.image = photo
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("touched photo at: \(indexPath.section) at \(indexPath.row)")
        guard let pin = self.pin, let pinPhotos = pin.photos else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        if let photo = pinPhotos[indexPath.row] as? Photo {
            PhotoController.delete(photo: photo, fromPin: pin)
            print("deleted photo")
            self.populateCollectionView()
        } else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
        }
        self.collectionView.reloadData()
    }
}

extension ViewController: MKMapViewDelegate {
    //to spruce up the annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
