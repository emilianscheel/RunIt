/**
*
*  LastRunsDetails.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/
import Foundation
import UIKit
import MapKit











class PastRunTitleCell: UITableViewCell {
	
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
}


class PastRunBadgeCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var valueLabel: UILabel!	
	@IBOutlet weak var icon: UIImageView!
}

class PastRunDatasCell: UITableViewCell {
	
	@IBOutlet weak var icon: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var valueLabel: UILabel!
}








protocol PastRunNotesCellDelegate {
	func textField(_ pastRunNotesCell: PastRunNotesCell, for valueChanged: String?)
}

class PastRunNotesCell: UITableViewCell {
	
	var delegate: PastRunNotesCellDelegate?
	
	@IBOutlet weak var textField: UITextField!
	
	@objc func valueChanged(_ sender: UITextField) {
		delegate?.textField(self, for: sender.text)
	}
	
	override func awakeFromNib() {
		textField.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
	}
}














class LastRunsDetails: UITableViewController {
	
	
	var currentRun: Run!
	var index: Int!
	var selIndex: IndexPath!
	var objectArray = [Object]()
	
	@IBOutlet weak var shareButton: UIButton!
	
	
	
	

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	
		
		
		// Füge die Titel-Section hinzu
		objectArray.append(Object(name: "", objects: [ObjectRowTitle(distance: currentRun.distance, date: currentRun.date!)], .title))
		
		
		
		
		
	
		var datas: [ObjectRowData] = []
		
		// Füge die formattierte Zeit zu den ‘datas‘
		let formattedDuration = FormatDisplay.duration.from(currentRun.duration)
		datas.append(ObjectRowData(name: "Zeit", value: formattedDuration, iconName: "timer"))
		// Füge das formattierte Pace  zu den ‘datas‘
		let formattedPace = FormatDisplay.pace.from(currentRun.duration, currentRun.distance).cropTo(sequences: 1).with(.pace)
		datas.append(ObjectRowData(name: "Pace min/km", value: formattedPace, iconName: "speedometer"))
		// Füge die formattierten KCal zu den ‘datas‘
		let formattedKCal = FormatDisplay.kCal.from(currentRun.duration)
		if  formattedKCal != "" {
			datas.append(ObjectRowData(name: "KCal", value: formattedKCal, iconName: "flame"))
		}
		// Füge die formattierten Schritte zu den ‘datas‘
		let stepWeight = AppSettings.doubleValue(.user_stepWeight)
		if stepWeight != nil {
			let formattedSteps = FormatDisplay.steps.from((currentRun.distance*100)/stepWeight!)
			datas.append(ObjectRowData(name: "Schritte", value: formattedSteps, iconName: "6.circle"))
		}
		
		// Füge die ‘datas‘-Section hinzu
		objectArray.append(Object(name: "Daten", objects: datas, .data))
		
		
		
		
		
		
		// Konvertiere alle Ziele zu [ObjectRowBadge]
		let allTargets = CoreDataStack.loadTargets()
		var targets: [ObjectRowBadge] = []
		for (index, target) in allTargets.enumerated() {
			targets.append(ObjectRowBadge(target, indexPath: IndexPath(row: index, section: 0)))
		}
		
		// Sortiere die Ziele nach Distanz
		targets.sort(by: { $0.target.distance < $1.target.distance })
		
		// Füge die Section-Ziele hinzu, wenn Ziele existieren
		if targets.count != 0 {
			objectArray.append(Object(name: "Ziele", objects: targets, .badge))
		}
		
		
		
		
		// Füge neue „Section“ für die Lauf-Notizen hinzu
		var notes: [ObjectRowNote] = []
		notes.append(ObjectRowNote(text: currentRun.notes ?? ""))
		objectArray.append(Object(name: "Notizen", objects: notes, .notes))
		
		
		
		
		// Erstelle ein Context-Menu für ‘shareButton‘
		var actions : [UIAction] = []
		
		// Füge die „Share Banner"-Action hinzu
		actions.append(UIAction(
			title: "Banner teilen",
			image: UIImage(systemName: "square.and.arrow.up")) { _ in
				
			self.createBanner()
		})
			 
		// Füge die „Create Banner"-Action hizu
		actions.append(UIAction(
			title: "Banner erstellen",
			image: UIImage(systemName: "plus")) { _ in
				
			self.performSegue(withIdentifier: .createBanner, sender: nil)
		})
		shareButton.menu = UIMenu(title: "", image: UIImage(named: ""), children: actions)
	}
	
	
	@IBAction func shareButtonTapped(_ sender: UIButton) {
		createBanner()
	}
	
	func createBanner() {
	
		let imageToShare = [ RunBanner.standard(for: currentRun) ]
		let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	@IBAction func fullScreenButtonTapped(_ sender: UIBarButtonItem) {
		
		// show comparingRunViewController
		self.performSegue(withIdentifier: .comparing, sender: nil)
	}
}

















/*

	MARK: LAST RUNS DETAILS - TABLEVIEW

	-numberOfSections
	-numberOfRowsInSection
	-cellForRowAt
	-titleForHeaderInSection
	-heightForRowAt

*/

extension LastRunsDetails {
		
	override func numberOfSections(in tableView: UITableView) -> Int {
		return objectArray.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objectArray[section].objects.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if objectArray[indexPath.section].kind == .title {
			
			// get data from objectArray with indexPath
			let data = objectArray[indexPath.section].objects[indexPath.row] as! ObjectRowTitle
			
			// get cell from tableView withIdentifier an indexPath as PastRunTitleCell
			let cell = tableView.dequeueReusableCell(withIdentifier: "PastRunTitleCell", for: indexPath as IndexPath) as! PastRunTitleCell
			
			// set data to labels
			cell.distanceLabel.text = FormatDisplay.distance.from(data.distance)
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium
			dateFormatter.timeStyle = .short
			cell.dateLabel.text = "am " + dateFormatter.string(from: data.date)
			
			// load map
			self.loadMap(for: cell.mapView)
			
			// remove possibillity to select
			cell.selectionStyle = .none
			
			// return customized cell
			return cell
			
		} else if objectArray[indexPath.section].kind == .data {
			
			// get data from objectArray with indexPath
			let data = objectArray[indexPath.section].objects[indexPath.row] as! ObjectRowData
			
			// get cell from tableView withIdentifier an indexPath as PastRunBadgeCell
			let cell = tableView.dequeueReusableCell(withIdentifier: "PastRunDatasCell", for: indexPath as IndexPath) as! PastRunDatasCell
			cell.icon.image = UIImage(systemName: data.icon)
			cell.titleLabel.text = data.name
			cell.valueLabel.text = data.value
			
			// remove possibillity to select
			cell.selectionStyle = .none
			
			// return customized cell
			return cell
			
		} else if objectArray[indexPath.section].kind == .badge {
			
			// get data from objectArray with indexPath
			let data = objectArray[indexPath.section].objects[indexPath.row] as! ObjectRowBadge
			
			// get cell from tableView withIdentifier an indexPath as PastRunBadgeCell
			let cell = tableView.dequeueReusableCell(withIdentifier: "PastRunBadgeCell", for: indexPath as IndexPath) as! PastRunBadgeCell
			cell.nameLabel.text = data.target.name
			
			var parameterCount = 0
			// Addiere 1 für jeden gegeben Parameter ‘parameterCount‘
			if data.target.distance != 0 { parameterCount += 1 }
			if data.target.duration != 0 { parameterCount += 1 }
			if data.target.pace != 0 { parameterCount += 1 }
			if data.target.location != nil { parameterCount += 1 }
			
			cell.valueLabel.text = "\(parameterCount) Stück"
			
			// set valueLabels textColor to systemRed if its distance is bigger than the distanc of the currentRun
			if TargetExtension.hasReached(currentRun, data.target) {
				cell.icon.image = UIImage(systemName: "arrow.down.left")
				cell.icon.tintColor = .systemRed
			} else {
				cell.icon.image = UIImage(systemName: "arrow.up.right")
				cell.icon.tintColor = .systemGreen
			}
			
			// return customized cell
			return cell
			
		} else if objectArray[indexPath.section].kind == .notes {
			
			// get data from objectArray with indexPath
			let data = objectArray[indexPath.section].objects[indexPath.row] as! ObjectRowNote
			
			// get cell from tableView withIdentifier an indexPath as PastRunBadgeCell
			let cell = tableView.dequeueReusableCell(withIdentifier: "PastRunNotesCell", for: indexPath as IndexPath) as! PastRunNotesCell
			cell.textField.text = data.text
			cell.textField.addTarget(cell, action: #selector(notesChanged(_:)), for: .valueChanged)
			
			// remove possibillity to select
			cell.selectionStyle = .none
			
			// return customized cell
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
			return objectArray[section].name
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if objectArray[indexPath.section].kind == .badge {
			self.performSegue(withIdentifier: .badgeDetails, sender: nil)
		}
	}
	
	@objc func notesChanged(_ sender: UITextView) {
		currentRun.notes = sender.text
		CoreDataStack.updateRun(at: index, newRun: currentRun)
	}
}



























/*

	MARK: LAST RUNS DETAILS - NOTES

	-valueChanged

*/

extension LastRunsDetails: PastRunNotesCellDelegate {
	
	func textField(_ pastRunNotesCell: PastRunNotesCell, for valueChanged: String?) {
		currentRun.notes = valueChanged
		CoreDataStack.updateRun(at: index, newRun: currentRun)
	}
}




























/*

	MARK: LAST RUNS DETAILS - MAPVIEW

	-loadMap
	-renderer

*/

extension LastRunsDetails: MKMapViewDelegate {
	
	func loadMap(for mapView: MKMapView) {
		mapView.delegate = self
		
		guard
			let locations = currentRun.locations,
			locations.count > 0,
			let region = MapExtension.mapRegion(currentRun)
		else {
			mapView.isHidden = true
			
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
		mapView.addOverlays(MapExtension.polyLine(isBlue: true, currentRun))
		mapView.addAnnotations(MapExtension.annotations(currentRun))
	}
		
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MulticolorPolyline else {
			return MKOverlayRenderer(overlay: overlay)
		}
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = polyline.color
		renderer.lineWidth = 5
		return renderer
	}
}






























/*

	MARK: LAST RUNS DETAILS - NAVIGATION

	-SegueIdentifier
	-prepare

*/

extension LastRunsDetails: SegueHandlerType {
	enum SegueIdentifier: String {
		case showMap = "PastRunMap"
		case comparing = "ComparePastRunSegue"
		case badgeDetails = "PastRunBadgeDetails"
		case createBanner = "LastRunDetailsCreateBanner"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
			
			case .showMap:
				let destination = segue.destination as! PastRunMap
				destination.currentRun = currentRun
				
			case .comparing:
				let destination = segue.destination as! CompareRuns
				destination.currentRun = currentRun
			
			case .badgeDetails:
				let destination = segue.destination as! BadgeDetails
				let indexPath = tableView.indexPathForSelectedRow!
				let data = self.objectArray[indexPath.section].objects[indexPath.row] as! ObjectRowBadge
				destination.currentTarget = data.target
				destination.indexPath = data.index
				
			case .createBanner:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as? CreateBanner
				viewController!.createBannerType = .run
				viewController!.standardTextLayers = CreateBanner.runLayers(for: currentRun)
				
		}
	}
}
