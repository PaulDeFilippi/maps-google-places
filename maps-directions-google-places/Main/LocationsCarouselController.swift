//
//  LocationsCarouselController.swift
//  maps-directions-google-places
//
//  Created by Paul Defilippi on 1/4/20.
//  Copyright © 2020 Paul Defilippi. All rights reserved.
//

import UIKit
import LBTATools
import MapKit

class LocationCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            label.text = item.name
            addressLabel.text = item.address()
//            let annotation = MKPointAnnotation()
//            let long = annotation.coordinate.longitude
//            let lat = annotation.coordinate.latitude
            
            let long = item.placemark.coordinate.longitude
            let lat = item.placemark.coordinate.latitude

            coordinateLabel.text = "\(long), \(lat)"
        }
    }
    
    override func setupViews() {
        backgroundColor = .white
        
        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .black)
        layer.cornerRadius = 5
        stack(label, addressLabel, coordinateLabel, spacing: 0, alignment: .top, distribution: .equalSpacing).withMargins(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 0))
    }
    
    let label = UILabel(text: "Location", font: .boldSystemFont(ofSize: 16), numberOfLines: 0)
    let addressLabel = UILabel(text: "Address", font: .systemFont(ofSize: 15), numberOfLines: 0)
    let coordinateLabel = UILabel(text: "coordinate", font: .italicSystemFont(ofSize: 12))
}

class LocationCarouselController: LBTAListController<LocationCell, MKMapItem> {
    
    weak var mainController: MainController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let annotations = mainController?.mapView.annotations
        annotations?.forEach({ (annotation) in
            if annotation.title == self.items[indexPath.item].name {
                mainController?.mapView.selectAnnotation(annotation, animated: true)
            }
        })
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        
//        let placemark = MKPlacemark(coordinate: .init(latitude: 10, longitude: 55))
//        let dummyMapItem = MKMapItem(placemark: placemark)
//        dummyMapItem.name = "Dummy location for example"
//        self.items = [dummyMapItem]
        
//        self.items = ["1", "2", "3"]
    }
    
}

extension LocationCarouselController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 64, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

}
