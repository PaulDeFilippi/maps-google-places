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
    }
    
    let locationsController = LocationCarouselController(scrollDirection: .horizontal)
    
    fileprivate func setupLocationsCarousel() {
        let locationsView = locationsController.view!
        view.addSubview(locationsView)
        locationsView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
    }
    
    class LocationCell: LBTAListCell<String> {
        override func setupViews() {
            backgroundColor = .red
            
            setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .black)
            layer.cornerRadius = 5
            clipsToBounds = false
        }
    }
    
    class LocationCarouselController: LBTAListController<LocationCell, String>, UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return .init(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return .init(width: view.frame.width - 64, height: view.frame.height)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 12
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            collectionView.clipsToBounds = false
            collectionView.backgroundColor = .clear
            
            self.items = ["1", "2", "3"]
        }
        
    }
    
    let searchTextField = UITextField(placeholder: "Search query")
    
    fileprivate func setupSearchUI() {
        let whiteContainerView = UIView(backgroundColor: .white)
        view.addSubview(whiteContainerView)
        whiteContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        
        whiteContainerView.stack(searchTextField).withMargins(.allSides(16))
        // listen for text changes - old school way
        //searchTextField.addTarget(self, action: #selector(handleSearchChanges), for: .editingChanged)
        
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
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (resp, err) in
            if let err = err {
                print("Failed local search:", err)
                //return
            }
            
            // remove old annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            resp?.mapItems.forEach({ (mapItem) in
                print(mapItem.address())
                
                
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
                
            })
            
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

extension MKMapItem {
    func address() -> String {
        var addressString = ""
        
        if placemark.subThoroughfare != nil {
            addressString = placemark.subThoroughfare! + " "
        }
        if placemark.thoroughfare != nil {
            addressString += placemark.thoroughfare! + ", "
        }
        if placemark.postalCode != nil {
            addressString += placemark.postalCode! + " "
        }
        if placemark.locality != nil {
            addressString += placemark.locality! + ", "
        }
        if placemark.administrativeArea != nil {
            addressString += placemark.administrativeArea! + " "
        }
        if placemark.country != nil {
            addressString += placemark.country!
        }
        return addressString
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
