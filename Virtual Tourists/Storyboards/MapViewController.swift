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
    var annotationsToShow = [MKPointAnnotation]()
    var annotationToPass: MKPointAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .includingAll
        mapView.isZoomEnabled = true
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
        
        //add new annotation to annotationsArray
        self.annotationsToShow.append(annotation)
        
        //add annotation to mapView
        mapView.addAnnotations(self.annotationsToShow)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCollectionView" {
            guard let destination = segue.destination as? ViewController, let annotationToPass = self.annotationToPass else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return
            }
            destination.annotation = annotationToPass
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
        self.annotationToPass = view.annotation as? MKPointAnnotation
        print("did select annotation")
        self.performSegue(withIdentifier: "toCollectionView", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("did deselect annotation")
    }
}
