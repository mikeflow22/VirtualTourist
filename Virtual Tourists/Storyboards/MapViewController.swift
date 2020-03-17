//
//  MapViewController.swift
//  Virtual Tourists
//
//  Created by Michael Flowers on 3/4/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    let pinController = PinController.shared
    var pinToPass: Pin?
    var annotationsToShow = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .includingAll
        mapView.isZoomEnabled = true
//        pinController.deleteAllpins(pins: pinController.pins)
        showAnnotationsFromCoreData()
    }
    
    @IBAction func tapAndHoldGesture(_ sender: UILongPressGestureRecognizer) {
        //get location
        let locationView = sender.location(in: mapView)
        
        //create annotation from said location
        let tappedCoordinates = mapView.convert(locationView, toCoordinateFrom: mapView)
        
        //create annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinates
        annotation.title = "title of annotation: \(annotation.coordinate)"
        
        if sender.state == .ended {
            print("Touch did end")
            //create and subsequently save new annotation to core data
            pinController.createPin(withLat: annotation.coordinate.latitude, andWithlon: annotation.coordinate.longitude)
            
            //add new annotation to annotationsArray
            self.annotationsToShow.append(annotation)
            
            //add annotation to mapView
            mapView.addAnnotations(self.annotationsToShow)
        }
    }
    
    func showAnnotationsFromCoreData(){
        if self.annotationsToShow.isEmpty {
            //fetch pins from CD
            for pin in pinController.pins {
                let pinCoordinates = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
                let annotation = MKPointAnnotation()
                annotation.coordinate = pinCoordinates
                self.annotationsToShow.append(annotation)
                self.mapView.addAnnotations(self.annotationsToShow)
            }
        } else {
            print("nothing was fetched from coreData")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCollectionView" {
            guard let destination = segue.destination as? ViewController, let pin = self.pinToPass else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return
            }
            destination.pin = pin
        }
    }
}

extension MapViewController: MKMapViewDelegate {
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
    
    //segue to collectionView if annotation is selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            let lat = annotation.coordinate.latitude
            let lon = annotation.coordinate.longitude
            
            //loop through the Pins to match coordinates
            for pin in pinController.pins {
                if pin.lat == lat && pin.lon == lon {
                    //assign pin to placeholder and segue the value over
                    self.pinToPass = pin
                }
            }
        }
        
        print("did select annotation")
        //deselect the annotation so that user can select another one
        mapView.deselectAnnotation(view.annotation, animated: true)
        self.performSegue(withIdentifier: "toCollectionView", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("did deselect annotation")
    }
}
