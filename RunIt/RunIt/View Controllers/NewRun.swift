/**
*
*  NewRun.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import CoreLocation
import MapKit
import AVFoundation
import Foundation

















class NewRun: UIViewController {
	
	@IBOutlet weak var distanceStackView: UIStackView!
	@IBOutlet weak var timeStackView: UIStackView!
	@IBOutlet weak var paceStackView: UIStackView!
	@IBOutlet weak var stopButton: UIButton!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var timeLabel_hours: UILabel!
	@IBOutlet weak var timeLabel_minutes: UILabel!
	@IBOutlet weak var timeLabel_seconds: UILabel!
	@IBOutlet weak var timeLabel_milli: UILabel!
	@IBOutlet weak var paceLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var connectionIcon: UIBarButtonItem!
	@IBOutlet weak var pauseButton: UIButton!
	
	
	// timer
	var timer = Timer()
	var isPaused = false
	var hrs = 0
	var min = 0
	var sec = 0
	var milliSecs = 0
	var diffHrs = 0
	var diffMins = 0
	var diffSecs = 0
	var diffMilliSecs = 0
	
	// run
	private var runs: [Run] = []
	private var run: Run?
	private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
	private let locationManager = LocationManager.shared
	private var seconds = 0
	private var distance = Measurement(value: 0, unit: UnitLength.kilometers)
	private var locationList: [CLLocation] = []
	private var upcomingBadge: Target!
	private var earnedGoals: [Target] = []
	var allCoordinates : [CLLocationCoordinate2D] = []
	
	
	
	
	
	
	// MARK: viewDidLoad
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set up shadows and border radius
		self.stopButton.withCorners(cornerRadius: 12.0)
		self.pauseButton.withCorners(cornerRadius: 12.0)
		
		// notify locked iphone
		NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: .UIApplicationDidEnterBackground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: .UIApplicationWillEnterForeground, object: nil)
		
		startRun()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.timer.invalidate()
		locationManager.stopUpdatingLocation()
	}
	
	
	
	
	
	
	
	@IBAction func stopTapped() {
		let alertController = UIAlertController(title: "Lauf beenden",
												message: "Möchtest du den Lauf wirklich beenden?",
												preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Zurück", style: .cancel))
		alertController.addAction(UIAlertAction(title: "Speichern", style: .default) { _ in
			self.stopRun()
			self.saveRun()
			self.performSegue(withIdentifier: .details, sender: nil)
		})
		alertController.addAction(UIAlertAction(title: "Löschen", style: .destructive) { _ in
			self.stopRun()
			_ = self.navigationController?.popToRootViewController(animated: true)
		})
		
		present(alertController, animated: true)
	}
	
	@IBAction func pauseButtonTapped(_ sender: UIButton) {
		switch isPaused {
			case true:
				
				// Run is paused -> start Run
				locationManager.startUpdatingLocation()
				timer = Timer.scheduledTimer(timeInterval: 0.016666666666667, target: self, selector: (#selector(updateLabels)), userInfo: nil, repeats: true)
				if #available(iOS 13.0, *) {
					self.pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
				}
				
			case false:
				
				// Run is running -> pause Run
				locationManager.stopUpdatingLocation()
				timer.invalidate()
				if #available(iOS 13.0, *) {
					self.pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
				}
		}
		
		isPaused = !isPaused
	}
	
	
	
	
	
	
	
	// MARK: - startRun
	
	private func startRun() {
		
		// allows background tasks
		backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
			UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
		})
		
		// allows background tasks for location
		locationManager.allowsBackgroundLocationUpdates = true
		
		// general set up
		seconds = 0
		distance = Measurement(value: 0, unit: UnitLength.meters)
		locationList.removeAll()
		//upcomingBadge = CoreDataStack.nextTarget(for: 0.0)
		updateDisplay()
		
		// start timer2
		self.timer = Timer.scheduledTimer(timeInterval: 0.016666666666667, target: self, selector: (#selector(updateLabels)), userInfo: nil, repeats: true)
		
		//
		startLocationUpdates()
	}
	
	
	
	
	
	// MARK: - stopRun
	
	private func stopRun() {
		timeStackView.isHidden = true
		distanceStackView.isHidden = true
		paceStackView.isHidden = true
		mapView.isHidden = true
		
		stopButton.isHidden = true
		
		locationManager.stopUpdatingLocation()
	}
	
	
	
	
	
	
	// MARK: - updateDisplay
	
	@objc private func updateDisplay() {
		
		// format totalSeconds from minutes, hours and seconds
		let seconds = (self.min*60) + (self.hrs/60) + self.sec
		
		let formattedDistance = FormatDisplay.distance.from(distance.value)
		let formattedPace = FormatDisplay.pace.from(seconds, distance.value).cropTo(sequences: 1)
		
		
	
		// set up labels
		distanceLabel.text = formattedDistance
		paceLabel.text = formattedPace
		
		// set the gps accuaracy as colors
		connectionIcon.tintColor = FormatDisplay.gps()
		
		//checkNextBadge()
	}
	
	
	
	
	
	// MARK: - startLocationUpdates
	
	private func startLocationUpdates() {
		let coordinates = locationManager.location?.coordinate
		if coordinates != nil {
			self.mapView.addAnnotations(self.getStartAnnotations(title: "Von hier gehts los!", coordinates: coordinates!) )
		}
		
		locationManager.delegate = self
		locationManager.activityType = .fitness
		locationManager.distanceFilter = 1
		locationManager.startUpdatingLocation()
	}
	
	
	
	
	
	// MARK: - getStartAnnotations
	
	private func getStartAnnotations(title:String, coordinates:CLLocationCoordinate2D) -> [MKAnnotation] {
		var annotations: [MKAnnotation] = []
		let annotation = MKPointAnnotation()
		annotation.title = title
		annotation.coordinate = coordinates
		annotations.append(annotation)
		return annotations
	}
	
	
	
	
	
	// MARK: - saveRun
	
	private func saveRun() {
		let newRun = Run(context: CoreDataStack.context)
		newRun.distance = distance.value
		newRun.duration = Int64(Int16((self.min*60) + (self.hrs*60*60) + self.sec))
		newRun.date = Date()
		
		for location in locationList {
			let locationObject = Location(context: CoreDataStack.context)
			locationObject.timestamp = location.timestamp
			locationObject.latitude = location.coordinate.latitude
			locationObject.longitude = location.coordinate.longitude
			newRun.addToLocations(locationObject)
		}
		
		CoreDataStack.saveContext()
		
		run = newRun
	}
	
	
	
	
	
	
	// MARK: - checkNextBadge
	
	private func checkNextBadge() {
		
		let meters = Measurement(value: distance.value, unit: UnitLength.meters).value
		let nextBadge = CoreDataStack.nextTarget(for: meters)
		
		if upcomingBadge != nextBadge {
			upcomingBadge = nextBadge
		}
	}
}





















/*

	MARK: NEW RUN - SEGUE

	-SegueIdentifier
	-prepare

*/

extension NewRun: SegueHandlerType {
	enum SegueIdentifier: String {
		case details = "RunDetailsViewController"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
			case .details:
				let destination = segue.destination as! NewRunDetails
				destination.currentRun = run
		}
	}
}


















/*

	MARK: NEW RUN - LOCATION

	-didUpdateLocation

*/

extension NewRun: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		for newLocation in locations {
			let howRecent = newLocation.timestamp.timeIntervalSinceNow
			
			// check howRecent and gpsAccuaracy
			guard (newLocation.horizontalAccuracy < AppSettings.doubleValue(.gpsAccuaracy) ?? 20.0) &&
					(abs(howRecent) < AppSettings.doubleValue(.howRecent) ?? 10.0)
			else { continue }
			
			if let lastLocation = locationList.last {
				let delta = newLocation.distance(from: lastLocation)
				distance = distance + Measurement(value: delta, unit: UnitLength.meters)
				let coordinates = [lastLocation.coordinate, newLocation.coordinate]
				
				allCoordinates.append(contentsOf: coordinates)
				
				mapView.add(MKPolyline(coordinates: coordinates, count: 2))
				let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
				mapView.setRegion(region, animated: true)
			}
			
			locationList.append(newLocation)
		}
	}
}























/*

	MARK: NEW RUN - MAPVIEW

	-rendererFor

*/

extension NewRun: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		
		guard let polyline = overlay as? MKPolyline else {
			return MKOverlayRenderer(overlay: overlay)
		}
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = .systemBlue
		renderer.lineWidth = 5
		return renderer
	}
}




















/*

	MARK: NEW RUN - TIMER

	-pauseWhenBackground
	-willEnterForeground
	-updateLabels
	-resetContent
	-getTimeDifference
	-refresh
	-invalidate
	-removeSavedDate

*/

extension NewRun {
	
	@objc func pauseWhenBackground(noti: Notification) {
		
		self.timer.invalidate()
		let shared = UserDefaults.standard
		shared.set(Date(), forKey: "savedTime")
	}
	
	@objc func willEnterForeground(noti: Notification) {
		
		if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
			(diffHrs, diffMins, diffSecs) = NewRun.getTimeDifference(startDate: savedDate)
			
			self.refresh(hours: diffHrs, mins: diffMins, secs: diffSecs)
		}
	}
	
	@objc func updateLabels() {
		
		if(self.milliSecs >= 59) {
			self.sec += 1
			self.milliSecs = 0
			if (self.sec >= 60) {
				self.min += self.sec/60
				self.sec = self.sec % 60
				if (self.min >= 60) {
					self.hrs += self.min/60
					self.min = self.min % 60
				}
			}
		} else {
			self.milliSecs += 1
		}
		self.timeLabel_milli.text = String(format: "%02d", self.milliSecs)
		self.timeLabel_seconds.text = String(format: "%02d", self.sec)
		self.timeLabel_minutes.text = String(format: "%02d", self.min)
		self.timeLabel_hours.text = String(format: "%02d", self.hrs)
		
		updateDisplay()
	}
	
	
	func resetContent() {
		self.removeSavedDate()
		timer.invalidate()
		self.timeLabel_milli.text = "00"
		self.timeLabel_seconds.text = "00"
		self.timeLabel_minutes.text = "00"
		self.timeLabel_hours.text = "00"
		self.milliSecs = 0
		self.sec = 0
		self.min = 0
		self.hrs = 0
	}
	
	
	static func getTimeDifference(startDate: Date) -> (Int, Int, Int) {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
		return(components.hour!, components.minute!, components.second!)
	}
	
	func refresh (hours: Int, mins: Int, secs: Int) {
		
		var minutes = self.min
		
		if (secs >= 60) {
			minutes += mins + secs/60
			self.sec = secs % 60
		} else {
			self.sec += secs
			minutes += mins
		}
		
		if (minutes >= 60) {
			self.hrs = hours + minutes/60
			self.min = minutes % 60
		} else {
			self.min = minutes
		}
		
		self.timeLabel_milli.text = String(format: "%02d", self.milliSecs)
		self.timeLabel_seconds.text = String(format: "%02d", self.sec)
		self.timeLabel_minutes.text = String(format: "%02d", self.min)
		self.timeLabel_hours.text = String(format: "%02d", self.hrs)
		
		self.timer = Timer.scheduledTimer(timeInterval: 0.016666666666667, target: self, selector: (#selector(updateLabels)), userInfo: nil, repeats: true)
	}
	
	func invalidate() {
		timer.invalidate()
	}
	
	private func removeSavedDate() {
		if (UserDefaults.standard.object(forKey: "savedTime") as? Date) != nil {
			UserDefaults.standard.removeObject(forKey: "savedTime")
		}
	}
}
