//
//  MainController.swift
//  maps-directions-google-places
//
//  Created by Paul Defilippi on 12/15/19.
//  Copyright © 2019 Paul Defilippi. All rights reserved.
//

import UIKit
import MapKit
import LBTATools

class HomeController: UIViewController {
    
    let mapView = MKMapView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        mapView.mapType = .hybridFlyover
        
//        mapView.translatesAutoresizingMaskIntoConstraints = false
//
//        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
