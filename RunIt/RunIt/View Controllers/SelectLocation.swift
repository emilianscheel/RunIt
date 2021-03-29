/**
*
*  SelectLocation.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import MapKit











class SelectLocation: UIViewController, UIGestureRecognizerDelegate {

	@IBOutlet weak var mapView: MKMapView!
	
	var delegate: SelectLocationDelegate?
	private let locationManager = LocationManager.shared
	var location: Location?
	
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
				
		// Setze die Region vom ‘mapView‘ auf die aktuelle Position
		let coordinates = self.locationManager.location?.coordinate
		if coordinates != nil {
			let region = MKCoordinateRegionMakeWithDistance(coordinates!, 5000, 5000)
			self.mapView.setRegion(region, animated: true)
		}
		
		if location != nil {
			// Füge ein ‘Annotation‘ hinzu, um den Ort zu markieren
			mapView.removeAnnotations(mapView.annotations)
			let annotation = MKPointAnnotation()
			annotation.coordinate = CLLocationCoordinate2D(latitude: location!.longitude, longitude: location!.latitude)
			mapView.addAnnotation(annotation)
		}

		let gestureZ = UILongPressGestureRecognizer(target: self, action: #selector(self.selectLocation(_:)))
		gestureZ.minimumPressDuration = 1
		gestureZ.delegate = self
		self.mapView.addGestureRecognizer(gestureZ)
    }
	
	
	
	
	@objc func selectLocation(_ sender: UILongPressGestureRecognizer) {
		
		let location = sender.location(in: mapView)
		let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
		
		// Füge ein ‘Annotation‘ hinzu, um den Ort zu markieren
		mapView.removeAnnotations(mapView.annotations)
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate
		mapView.addAnnotation(annotation)
		
		// Erstelle ein neues LocationObject mit dem ausgewählten Standort
		let locationObject = Location(context: CoreDataStack.context)
		locationObject.latitude = coordinate.latitude
		locationObject.longitude = coordinate.longitude
		self.location = locationObject
	}
	
	@IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
		if location != nil {
			self.delegate!.locationSelected(location: location!)
			self.dismiss(animated: true, completion: nil)
		} else {
			let alert = UIAlertController(title: "Fehler",
										  message: "Wähle einen Ort aus, indem du ihn 1 Sekunde gedrückt hälst.",
										  preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
				
			}))
			present(alert, animated: true)
		}
	}
}


protocol SelectLocationDelegate {
	func locationSelected(location: Location)
}

