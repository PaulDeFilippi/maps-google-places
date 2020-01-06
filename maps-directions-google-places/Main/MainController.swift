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

extension MainController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
        annotationView.image = #imageLiteral(resourceName: "tourist")
        return annotationView
    }
}

class MainController: UIViewController {
    
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        setupRegionForMap()
        
        //setupAnnotationsForMap()
        
        performLocalSearch()
        setupSearchUI()
        setupLocationsCarousel()
        locationsController.mainController = self
    }
    
    let locationsController = LocationCarouselController(scrollDirection: .horizontal)
    
    fileprivate func setupLocationsCarousel() {
        let locationsView = locationsController.view!
        view.addSubview(locationsView)
        locationsView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
    }

    let searchTextField = UITextField(placeholder: "Search query")
    
    fileprivate func setupSearchUI() {
        let whiteContainerView = UIView(backgroundColor: .white)
        view.addSubview(whiteContainerView)
        whiteContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        
        whiteContainerView.stack(searchTextField).withMargins(.allSides(16))
        // listen for text changes - old school way
        searchTextField.addTarget(self, action: #selector(handleSearchChanges), for: .editingChanged)
        
        // new school - search throttling
        // search on the last keystroke of text changes and wait 500ms
        
        _ = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { (_) in
                print(121212121)
                self.performLocalSearch()
        }
        
    }
    
    @objc fileprivate func handleSearchChanges() {
        performLocalSearch()
    }
    
    fileprivate func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mapView.region
        
        mapView.annotations.forEach { (annotation) in
            if annotation.title == "TEST" {
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (resp, err) in
            if let err = err {
                print("Failed local search:", err)
                return
            }
            
            // remove old annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.locationsController.items.removeAll()
            
            resp?.mapItems.forEach({ (mapItem) in
                print(mapItem.address())
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
                
                self.locationsController.items.append(mapItem)
            })

            self.locationsController.collectionView.scrollToItem(at:[0, 0], at: .centeredHorizontally, animated: true)
            
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    fileprivate func setupAnnotationsForMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        annotation.title = "San Francisco"
        annotation.subtitle = "CA"
        mapView.addAnnotation(annotation)
        
        let appleCampusAnnotation = MKPointAnnotation()
        appleCampusAnnotation.coordinate = .init(latitude: 37.3326, longitude: -122.030024)
        appleCampusAnnotation.title = "Apple Campus"
        appleCampusAnnotation.subtitle = "Cupertino, CA"
        mapView.addAnnotation(appleCampusAnnotation)
        
        mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    fileprivate func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 34.8519, longitude: -82.385318)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

// SwiftUI Preview
import SwiftUI

struct MainPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) -> MainController {
            return MainController()
        }
        
        func updateUIViewController(_ uiViewController: MainController, context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) {
        }
        
        typealias UIViewControllerType = MainController
    }
}
