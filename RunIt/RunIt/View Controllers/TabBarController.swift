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

class TabBarController: UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setze den Index vom aktuellen Tab auf 2
		self.selectedIndex = 2
		
		
		// Füge den abgerundeten Button in der Mitte hinzu
		let middleButton = RoundedTabBar.middleButton(for: self.view)
		self.tabBar.addSubview(middleButton)
		self.view.layoutIfNeeded()
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
		
		
		// Bring den ‘newRunButton‘ nach vorne, um ihn sichtbar zu machen
		view.bringSubview(toFront: newRunButton)
		
		let coordinates = self.locationManager.location?.coordinate
		if coordinates != nil {
			let region = MKCoordinateRegionMakeWithDistance(coordinates!, 500, 500)
			self.mapView.setRegion(region, animated: true)
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
			let region = MKCoordinateRegionMakeWithDistance(coordinates!, 500, 500)
			self.mapView.setRegion(region, animated: true)
			
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
