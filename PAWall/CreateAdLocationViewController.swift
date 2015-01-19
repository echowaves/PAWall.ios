//
//  CreateAdLocationViewController.swift
//  PAWall
//
//  Created by D on 1/12/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation
import MapKit


class CreateAdLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchLocationBar: UISearchBar!
   
    var phoneNumber = ""
    var adDescription = ""
    
    var geoPoint:PFGeoPoint = PFGeoPoint()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            var location = CLLocationCoordinate2D(
                latitude: 51.50007773,
                longitude: -0.1246402
            )
            
            if error == nil {
                // do something with the new geoPoint
                // 1
                location = CLLocationCoordinate2D(
                    latitude: geoPoint.latitude,
                    longitude: geoPoint.longitude
                )
                
            }
            
            // 2
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            self.mapView.setRegion(region, animated: true)
            
            //3
            let annotation = MKPointAnnotation()
            annotation.setCoordinate(location)
            annotation.title = "My Location"
            annotation.subtitle = "Mobile"
            self.mapView.addAnnotation(annotation)
            
            self.geoPoint = geoPoint
            
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("----------------seguiing \(segue.identifier)")
     
        
        // Make sure your segue name in storyboard is the same as this line
        if segue.destinationViewController.isKindOfClass(HomeViewControler)
        {
            NSLog("----calling prepareForSegue unwind")
            var classifiedAd = PFObject(className:CLASSIFIED_AD.CLASS_NAME)
            classifiedAd[CLASSIFIED_AD.DEVICE_TOKEN] = DEVICE_TOKEN
            classifiedAd[CLASSIFIED_AD.PHONE_NUMBER] = phoneNumber
            classifiedAd[CLASSIFIED_AD.DESCRIPTION] = adDescription
            classifiedAd[CLASSIFIED_AD.LOCATION] = geoPoint
            classifiedAd.saveInBackgroundWithBlock(nil)
        }
    }
    
}