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
            loadViewIfNeeded()
            print("annotation was hit in the view controller")
            addAnnotation()
            populateCollectionView()
            self.collectionView.reloadData()
        }
    }
    
    func addAnnotation(){
        guard let annotation = self.annotation, isViewLoaded else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.region = region
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
        networkController.photoImagesOfCurrentNetworkCall.removeAll()
    }
    
    func populateCollectionView(){
        guard let annotation = self.annotation, isViewLoaded else {
                  print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                  return
              }
        
        networkCall(lat: annotation.coordinate.latitude, lon: annotation.coordinate.longitude)
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
//                print("Images array count: \(NetworkController.shared.photoImages.count)")
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return networkController.photoImagesOfCurrentNetworkCall.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = networkController.photoImagesOfCurrentNetworkCall[indexPath.item]
        cell.photoImageView.image =  photo
        return cell
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
