/**
*
*  PastRunMap.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import MapKit










class PastRunMap: UIViewController {
	
	var currentRun: Run!
	var bluePolyline = true
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var showMoreButton: UIBarButtonItem!
	@IBOutlet weak var keyMap: UIView!
	
	
	
	
	
	
	// MARK: viewDidLoad
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.bringSubview(toFront: keyMap)
		self.keyMap.isHidden = true
		
		loadMap()
	}
	
	
	
	
	
	
	
	
	
	@IBAction func backButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func showMoreButtonTapped(_ sender: UIBarButtonItem) {
		if bluePolyline {
			showMoreButton.title = "Weniger"
			keyMap.isHidden = false
		} else {
			showMoreButton.title = "Mehr"
			keyMap.isHidden = true
		}
		bluePolyline = !bluePolyline
		loadMap()
	}
}



















/*

	MARK: PAST RUNS MAP - MAPVIEW

	-renderer
	-loadMap

*/

extension PastRunMap: MKMapViewDelegate {
		
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MulticolorPolyline else {
			return MKOverlayRenderer(overlay: overlay)
		}
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = polyline.color
		renderer.lineWidth = 5
		return renderer
	}
	
	func loadMap() {
		self.mapView.delegate = self
		
		guard
			let locations = currentRun.locations,
			locations.count > 0,
			let region = MapExtension.mapRegion(currentRun)
		else {
			let alert = UIAlertController(title: "Fehler",
										  message: "Für diesen Lauf sind keine Punkte gespeichert.",
										  preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel))
			present(alert, animated: true)
			return
		}
		
		mapView.setRegion(region, animated: true)
		mapView.addOverlays(MapExtension.polyLine(isBlue: bluePolyline, currentRun))
		mapView.addAnnotations(MapExtension.annotations(currentRun))
	}
}
