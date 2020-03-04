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

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .includingAll
        mapView.isZoomEnabled = true
    }
    
    @IBAction func tapAndHoldGesture(_ sender: UILongPressGestureRecognizer) {
        print("testing")
        //get location
        let locationView = sender.location(in: mapView)
        print("locationView: \(locationView.x)")
        let tappedCoordinates = mapView.convert(locationView, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinates
        annotation.title = "\(annotation.coordinate)"
        mapView.addAnnotation(annotation)
        //create annotation from said location
        //segue
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
        self.performSegue(withIdentifier: "toCollectionView", sender: self)
    }
}
