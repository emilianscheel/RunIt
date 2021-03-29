/**
*
*  TabBarController.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import MapKit
import CoreData
import WidgetKit







class TabBarController: UITabBarController {
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setze den Index vom aktuellen Tab auf 2
		self.selectedIndex = 1
		
		
		// Füge den abgerundeten Button in der Mitte hinzu
		let middleButton = RoundedTabBar.middleButton(for: self.view)
		middleButton.addTarget(nil, action: #selector(newRunSelected), for: .touchUpInside)
		self.tabBar.addSubview(middleButton)
		self.view.layoutIfNeeded()
	}
	
	@objc func newRunSelected() {
		self.selectedIndex = 1
	}
}





















class Dashboard: UIViewController {
	
	@IBOutlet weak var newRunButton: UIButton!
	@IBOutlet weak var mapView: MKMapView!
	
	private let locationManager = LocationManager.shared
	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Zeige die ‘tabBar‘, wenn das ‘view‘ angezeigt wird
		self.tabBarController?.tabBar.isHidden = false
		
		
		// Lade die Widgets neu
		WidgetCenter.shared.reloadAllTimelines()
		
		
		// Bring den ‘newRunButton‘ nach vorne, um ihn sichtbar zu machen
		view.bringSubviewToFront(newRunButton)
		
		let coordinates = self.locationManager.location?.coordinate
		if coordinates != nil {
			//let region = MKCoordinateRegion(center: coordinates!, latitudinalMeters: 500, longitudinalMeters: 500)
			//self.mapView.setRegion(region, animated: true)
			
			let eyeCoordinates = CLLocationCoordinate2D(latitude: coordinates!.latitude + 0.01, longitude: coordinates!.longitude + 0.01)
			let camera = MKMapCamera(lookingAtCenter: coordinates!, fromEyeCoordinate: eyeCoordinates, eyeAltitude: 1000)
			mapView.setCamera(camera, animated: true)
			
			self.startLocationUpdates()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Zeige die ‘tabBar‘, wenn das ‘view‘ angezeigt wird
		self.tabBarController?.tabBar.isHidden = false
	}
	
	
	
	
	

	@IBAction func newRunButtonTapped(_ sender: UIButton) {
		self.performSegue(withIdentifier: .newRun, sender: nil)
	}
}





















/*

	MARK: DASHBOARD - MAPVIEW

	-didUpdateLocations
	-startLocationUpdates

*/

extension Dashboard: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		let coordinates = self.locationManager.location?.coordinate
		if coordinates != nil {
			//let region = MKCoordinateRegion(center: coordinates!, latitudinalMeters: 500, longitudinalMeters: 500)
			//self.mapView.setRegion(region, animated: true)
			
			let eyeCoordinates = CLLocationCoordinate2D(latitude: coordinates!.latitude + 0.01, longitude: coordinates!.longitude + 0.01)
			let camera = MKMapCamera(lookingAtCenter: coordinates!, fromEyeCoordinate: eyeCoordinates, eyeAltitude: 1000)
			mapView.setCamera(camera, animated: false)
			self.startLocationUpdates()
		}
	}
	
	private func startLocationUpdates() {
		locationManager.delegate = self
		locationManager.activityType = .other
		locationManager.startUpdatingLocation()
	}
}





























/*
	  MARK: DASHBOARD - NAVIGATION
 
	-sequeIdentifier
	-prepare

*/

extension Dashboard: SegueHandlerType {
	enum SegueIdentifier: String {
		case newRun = "StartNewRunSegue"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
			
			case .newRun:
				break
		}
	}
}
