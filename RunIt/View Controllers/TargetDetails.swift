/**
*
*  GoalsDetail.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import MapKit












class BadgeDetailsRunCell: UITableViewCell {
	
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var iconView: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var paceLabel: UILabel!
}

class BadgeDetailsTitleCell: UITableViewCell {
	
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var mapView: MKMapView!
}

class BadgeDetailsTargetCell: UITableViewCell {
	
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var subtitle: UILabel!
	@IBOutlet weak var iconView: UIImageView!
}












class BadgeDetails: UITableViewController, ModalTransitionListener {
	
	@IBOutlet weak var editButton: UIBarButtonItem!
	var indexPath: IndexPath!
	var targets: [Target] = []
	var currentTarget: Target!
	var qualifiedRuns: [Run] = []
	var sectionArray = [Objects]()
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureView()
	}
	
	func configureView() {
		
		// Lade alle Ziele und überschreibe ‘currentBadge‘ mit dem zu dem ViewController gegebenen IndexPath
		targets = CoreDataStack.loadTargets()
		
		// Set ModalTransitionMediator listener to ‘self‘
		ModalTransitionMediator.instance.setListener(listener: self)
		
		// Lösche alle Inhalte aus ‘sectionArray‘
		sectionArray = []
		
		// Füge den Titel zu ‘sectionArray‘ hinzu
		sectionArray.append(Objects(name: "", objects: [ObjectRowTitle(title: currentTarget.name!, distance: currentTarget.distance)], .title))
		
		
		// Füge alle Daten zum aktuellen Ziel hinzu, sofern sie vorhanden sind
		var targets: [ObjectRowTarget] = []
		
		if currentTarget.distance != 0 {
			let formattedDistance = FormatDisplay.distance.from(currentTarget.distance)
			targets.append(ObjectRowTarget(name: "Distanz", value: formattedDistance, iconName: "location.north.line"))
		}
		
		if currentTarget.duration != 0 {
			let formattedDuration = FormatDisplay.duration.from(currentTarget.duration)
			targets.append(ObjectRowTarget(name: "Zeit", value: formattedDuration, iconName: "timer"))
		}
		
		if currentTarget.pace != 0 {
			let formattedPace = currentTarget.pace.cropTo(sequences: 1)
			targets.append(ObjectRowTarget(name: "Pace min/km", value: formattedPace, iconName: "speedometer"))
		}
		
		if targets.count != 0 {
			sectionArray.append(Objects(name: "Ziele", objects: targets, .targets))
		}
		
		
		
		
		
		// Konvertiere alle Läufe zu [ObjectRowRun]
		let allRuns = CoreDataStack.loadRuns()
		var runs: [ObjectRowRun] = []
		for run in allRuns {
			runs.append(ObjectRowRun(run: run))
		}
		
		// Sortiere die Läufe nach Distanz
		runs.sort(by: { !TargetExtension.hasReached($0.run, currentTarget) && TargetExtension.hasReached($1.run, currentTarget) })
		
		// Füge die Section-Ziele hinzu, wenn Ziele existieren
		if runs.count != 0 {
			sectionArray.append(Objects(name: "Läufe", objects: runs, .runs))
		}
		
		self.tableView.reloadData()
	}
	
	func popoverDismissed() {
		configureView()
	}

	@IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
		self.performSegue(withIdentifier: .editBadge, sender: nil)
	}
}


























/*

	MARK: BADGE DETAILS - TABLEVIEW

	-numberOfSections
	-numberOfRowsInSection
	-cellForRowAt
	-titleForHeaderInSection
	-didSelectedRowAt

*/

extension BadgeDetails {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sectionArray.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sectionArray[section].objects.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if sectionArray[indexPath.section].kind == .title {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeDetailsTitleCell", for: indexPath) as! BadgeDetailsTitleCell
			
			cell.title.text = currentTarget.name!
			self.loadMap(for: cell.mapView)
			
			// Setze den ‘selectionStyle‘ auf ‘none‘, um eine Auswähl der Zellen zu verhindern
			cell.selectionStyle = .none
			
			return cell
			
			
			
		} else if sectionArray[indexPath.section].kind == .runs {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeDetailsEarnedCell", for: indexPath) as! BadgeDetailsRunCell
			let currentRun = self.sectionArray[indexPath.section].objects[indexPath.row] as! ObjectRowRun
						
			cell.distanceLabel.text = FormatDisplay.distance.from(currentRun.run.distance)
			cell.durationLabel.text = FormatDisplay.duration.from(currentRun.run.duration)
			cell.paceLabel.text = FormatDisplay.pace.from(currentRun.run.duration, currentRun.run.distance).cropTo(sequences: 1).with(.pace)
			cell.dateLabel.text = FormatDisplay.date.from(date: currentRun.run.date!, "dd. MMM")
			
			// Markiere den Parameter, wenn ein Ziel für diesen Parameter festgelegt ist
			if currentTarget.distance != 0 {
				cell.distanceLabel.font = .boldSystemFont(ofSize: 17.0)
			}
			if currentTarget.duration != 0 {
				cell.durationLabel.font = .boldSystemFont(ofSize: 17.0)
			}
			if currentTarget.pace != 0 {
				cell.paceLabel.font = .boldSystemFont(ofSize: 17.0)
			}
			
			// Setzte die Farbe vom iconView zu ‘red‘, wenn der Lauf kürzer ist als die Strecke vom Ziel
			if TargetExtension.hasReached(currentRun.run, currentTarget) {
				cell.iconView.image = UIImage(systemName: "arrow.down.left")
				cell.iconView.tintColor = .systemRed
			} else {
				cell.iconView.image = UIImage(systemName: "arrow.up.right")
				cell.iconView.tintColor = .systemGreen
			}
			
			// Setze den ‘selectionStyle‘ auf ‘none‘, um eine Auswähl der Zellen zu verhindern
			cell.selectionStyle = .none
			
			return cell
			
			
		} else if sectionArray[indexPath.section].kind == .targets {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeDetailsTargetCell", for: indexPath) as! BadgeDetailsTargetCell
			let currentTarget = self.sectionArray[indexPath.section].objects[indexPath.row] as! ObjectRowTarget
			
			cell.title.text = currentTarget.name
			cell.subtitle.text = currentTarget.value
			cell.iconView.image = currentTarget.icon
			
			// Setze den ‘selectionStyle‘ auf ‘none‘, um eine Auswähl der Zellen zu verhindern
			cell.selectionStyle = .none
			
			return cell
			
			
		} else {
			
			// get cell from tableView withIdentifier an indexPath as PastRunBadgeCell
			let cell = tableView.dequeueReusableCell(withIdentifier: "PastRunBadgeCell", for: indexPath as IndexPath)
			
			return cell
			
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return nil
		} else {
			return sectionArray[section].name
		}
	}
	
	func loadMap(for mapView: MKMapView) {
		
		if currentTarget.location != nil {
			// Füge ein ‘Annotation‘ hinzu, um den Ort zu markieren
			mapView.removeAnnotations(mapView.annotations)
			let annotation = MKPointAnnotation()
			annotation.coordinate = CLLocationCoordinate2D(latitude: currentTarget.location!.latitude, longitude: currentTarget.location!.longitude)
			mapView.addAnnotation(annotation)
			
			let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
			mapView.setRegion(region, animated: true)
		} else {
			mapView.isHidden = true
		}
	}
}





























/*

	MARK: BADGE DETAILSs - OBJECT CLASS

	-Object
	-ObjectRowKind

	-ObjectRow
	-ObjectRowTitle
	-ObjectRowRun

*/

extension BadgeDetails {
	
	
	struct Objects {
		var name : String!
		var objects : [ObjectRow]!
		var kind: ObjectRowKind!
		
		init(name: String, objects: [ObjectRow], _ kind: ObjectRowKind) {
			self.name = name
			self.objects = objects
			self.kind = kind
		}
	}

	enum ObjectRowKind {
		case title
		case runs
		case targets
	}
	
	class ObjectRow {  }
	
	class ObjectRowTitle: ObjectRow {
		var title: String!
		var distance: Double!
		
		init(title: String, distance: Double) {
			self.title = title
			self.distance = distance
		}
	}
	
	class ObjectRowRun: ObjectRow {
		var run: Run!
		
		init(run: Run) {
			self.run = run
		}
	}
	
	class ObjectRowTarget: ObjectRow {
		var name: String!
		var value: String!
		var icon: UIImage!
		
		init(name: String, value: String, iconName: String = "") {
			self.name = name
			self.value = value
			self.icon = UIImage(systemName: iconName)!
		}
	}
}

























/*

	MARK: BADGE DETAILS - NAVIGATION

	-segueIdentifier
	-prepare

*/

extension BadgeDetails: SegueHandlerType {
	enum SegueIdentifier: String {
		case editBadge = "EditBadgeSegue"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
			
			case .editBadge:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as? CreateTarget
				viewController?.editingStyle = .edit
				viewController?.indexPath = indexPath
		}
	}
}
