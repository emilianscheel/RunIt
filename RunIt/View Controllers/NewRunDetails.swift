
/**
*
*  NewRunDetails.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import MapKit
import CoreData













class NewRunDetails: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var paceLabel: UILabel!
	
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var qualifiedRunsButton: UIButton!
	
	var currentRun: Run!
	var sharedAlready = false
	
	
	
	
	// MARK: viewDidLoad
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.mapView.delegate = self
		
		// Formatiere die Zeit, Distanz, das Datum und Pace min/km
		let formattedDuration = FormatDisplay.duration.from(currentRun.duration)
		let formattedDistance = FormatDisplay.distance.from(currentRun.distance)
		let formattedDate = FormatDisplay.date.from(date: currentRun.date ?? Date(), "dd.MM.yyyy")
		let formattedPace = FormatDisplay.pace.from(currentRun.duration, currentRun.distance).cropTo(sequences: 1).with(.pace)
		
		// Setze den Text von Labels auf die formatierten Werte
		distanceLabel.text = formattedDistance
		durationLabel.text = formattedDuration
		dateLabel.text = formattedDate
		paceLabel.text = formattedPace
		
		// Lade die erstellte Karte
		loadMap()
		
		// Runde die Ecken der Buttons ab
		self.backButton.withCorners(cornerRadius: 12.0)
		self.qualifiedRunsButton.withCorners(cornerRadius: 12.0)
	}
	
	
	
	
	
	
	

	
	@IBAction func backButtonTapped(_ sender: UIButton) {
		if AppSettings.boolValue(.shareNewRun) && sharedAlready == false  {
			sharedAlready = true
			self.performSegue(withIdentifier: .share, sender: nil)
		} else {
			self.navigationController?.popToRootViewController(animated: true)
		}
	}
		
	@IBAction func qualifiedRunsTapped(_ sender: UIButton) {
		self.performSegue(withIdentifier: .pastRuns, sender: nil)
	}
		
	@IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
		
		let imageToShare = [ RunBanner.standard(for: currentRun) ]
		let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	@IBAction func fullScreenButtonTapped(_ sender: UIBarButtonItem) {
		self.performSegue(withIdentifier: .map, sender: nil)
	}
}


























/*

	MARK: NEW RUN DETAILS - MAPVIEW

	-rendererFor
	-loadMap

*/

extension NewRunDetails: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MulticolorPolyline else {
			return MKOverlayRenderer(overlay: overlay)
		}
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = polyline.color
		renderer.lineWidth = 5
		return renderer
	}
	
	private func loadMap() {
		guard
			let locations = currentRun.locations,
			locations.count > 0,
			let region = MapExtension.mapRegion(currentRun)
		else {
			if AppSettings.boolValue(.alert_showNoLocationsSaved) == false {
				let alert = UIAlertController(title: "Fehler",
											  message: "Für diesen Lauf sind keine Punkte gespeichert.",
											  preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Nicht mehr anzeigen", style: .default, handler: {_ in
					AppSettings[.alert_showNoLocationsSaved] = true
				}))
				alert.addAction(UIAlertAction(title: "OK", style: .cancel))
				present(alert, animated: true)
			}
			return
		}
		
		mapView.setRegion(region, animated: true)
		mapView.addOverlays(MapExtension.polyLine(isBlue: false, currentRun))
		mapView.addAnnotations(MapExtension.annotations(currentRun))
	}
}



















/*

	MARK: NEW RUN DETAILS - NAVIGATION

	-segueIdentifier
	-prepare

*/

extension NewRunDetails: SegueHandlerType {
	enum SegueIdentifier: String {
		case pastRuns = "CompareNewRunSegue"
		case map = "NewRunMap"
		case share = "ShareNewRunSegue"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
			case .pastRuns:
				let destination = segue.destination as! CompareRuns
				destination.currentRun = currentRun
				
			case .map:
				let destination = segue.destination as! PastRunMap
				destination.currentRun = currentRun
				
			case .share:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as? CreateBanner
				viewController!.createBannerType = .run
				viewController!.standardTextLayers = CreateBanner.runLayers(for: currentRun)
		}
	}
}
