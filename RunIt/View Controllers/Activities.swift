/**
*
*  PastRunsTable.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import CoreData
import MapKit











class ActivityCell: UITableViewCell {
	
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
}


















class Activities: UITableViewController {
	
	
	
	@IBOutlet weak var btnEdit: UIBarButtonItem!
	@IBOutlet weak var btnAddManually: UIBarButtonItem!
	@IBOutlet weak var segmentControl: UISegmentedControl!
	
	var runs: [Run] = []
	var targets: [Target] = []
	var filteredRuns = [GroupSections.Object]()
	var selIndex: IndexPath = IndexPath(row: 0, section: 0)
	
	
	
	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Lade die Läufe und sortiere sie
		refresh()
		
		// Setzte ‘delegate‘ von der SearchBar zu ‘self‘
		let searchController = UISearchController(searchResultsController: nil)
		searchController.searchBar.delegate = self
		searchController.searchBar.showsCancelButton = false
		searchController.hidesNavigationBarDuringPresentation = false
		navigationItem.hidesSearchBarWhenScrolling = true
		navigationItem.searchController = searchController
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refresh()
		
		// Zeige die TabBar, wenn der ViewController angezeigt wird
		self.tabBarController?.tabBar.isHidden = false
	}
	
	
	
	
	@objc func refresh() {
		
		// Lade die letzten Läufe aus CoreData, gruppiere sie nach Monat und sortiere nach Datum
		runs = CoreDataStack.loadRuns()
		targets = CoreDataStack.loadTargets()
		self.filteredRuns = GroupSections.group(runs, by: .month)
		self.filteredRuns.sort { lhs, rhs in lhs.date < rhs.date }
		
		// Aktualisiere ‘tableView‘ mit den neuen Daten
		tableView.reloadData()
	}
	
	@IBAction func segmentChanged(_ sender: UISegmentedControl) {
		refresh()
	}
	
	@IBAction func addTapped(_ sender: UIBarButtonItem) {
		if segmentControl.selectedSegmentIndex == 0 {
			self.performSegue(withIdentifier: .createRun, sender: nil)
		} else {
			self.performSegue(withIdentifier: .createTarget, sender: nil)
		}
	}
	
	@IBAction func editModeChanged(_ sender: UIBarButtonItem) {
		self.navigationItem.searchController!.isActive = !self.navigationItem.searchController!.isActive
		self.navigationItem.searchController!.isEditing = !self.navigationItem.searchController!.isEditing
		self.navigationItem.searchController?.searchBar.setShowsCancelButton(!(navigationItem.searchController?.searchBar.showsCancelButton)!, animated: true)
	}
}










extension Activities: CreateRunDelegate {
	
	func didFinishedCreating(run: Run?) {
		refresh()
	}
}

extension Activities: CreateTargetDelegate {
	
	func didFinishedCreating(target: Target?) {
		refresh()
	}
}

















/*
	  MARK: PAST RUNS TABLE - SEARCH
 
	-textDidChange
	-didBeginEditing
	-cancelButtonClicked

 */

extension Activities: UISearchBarDelegate {
		
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
	
		if segmentControl.selectedSegmentIndex == 0 {
			runs = searchText.isEmpty ? runs : runs.filter { (item: Run) -> Bool in
				// Erstelle ein DateFormatter
				let formatter = DateFormatter()
				formatter.dateStyle = .medium
				formatter.timeStyle = .medium
				
				// Formatiere die Distanz, die Zeit und das Datum für die Suche
				let distance = FormatDisplay.distance.from(item.distance)
				let duration = FormatDisplay.duration.from(item.duration)
				let date = formatter.string(from: item.date ?? Date())
				
				let throughSearchedText = distance + " " + duration + " " + date
				return throughSearchedText.contains(searchText)
			}
			
			self.filteredRuns = GroupSections.group(runs, by: .month)
			self.filteredRuns.sort { lhs, rhs in lhs.date < rhs.date }
			
			self.tableView.reloadData()
		} else {
			targets = searchText.isEmpty ? targets : targets.filter { (item: Target) -> Bool in
				
				// Wenn das aktuelle Target in dem ‘searchText‘ vorkommt, dann gebe ‘true‘ zurück, um es in den Suchergebnissen anzuzeigen
				let distance = FormatDisplay.distance.from(item.distance)
				let duration = FormatDisplay.duration.from(item.duration)
				let pace = FormatDisplay.pace.from(item.duration, item.distance).cropTo(sequences: 1).with(.pace)
				
				let throughSearchedText = item.name! + " " + distance + " " + duration + " " + pace
				return throughSearchedText.contains(searchText)
			}
			self.tableView.reloadData()
		}
	}
		
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.navigationItem.searchController?.searchBar.setShowsCancelButton(true, animated: true)
	}
		
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(false, animated: true)
		searchBar.text = ""
		searchBar.resignFirstResponder()
		refresh()
	}
}





























/*
	  MARK: PAST RUNS TABLE - TABLEVIEW
 
	-numberOfItemsInSection
	-cellForItemAt
	-contextMenuForCell
	-editingStyle

 */


extension Activities {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if segmentControl.selectedSegmentIndex == 0 {
			if filteredRuns.count == 0 {
				self.tableView.addMessage("Keine letzten Läufe")
			} else {
				self.tableView.restore()
			}
			return filteredRuns.count
		} else {
			if targets.count == 0 {
				self.tableView.addMessage("Keine Ziele festgelegt")
			} else {
				self.tableView.restore()
			}
			return 1
		}
	}
		
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if segmentControl.selectedSegmentIndex == 0 {
			let section = filteredRuns[section]
			return section.rows.count
		} else {
			return targets.count
		}
	}
		
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if segmentControl.selectedSegmentIndex == 0 {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "ActivitieCell", for: indexPath) as! ActivityCell
			let sections = self.filteredRuns[indexPath.section]
			let pastRun = sections.rows[indexPath.row] as! ObjectRowRun
			cell.distanceLabel.text = FormatDisplay.distance.from(pastRun.run.distance)
			cell.durationLabel.text = FormatDisplay.duration.from(pastRun.run.distance)
			return cell
			
		} else {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "ActivitieCell", for: indexPath) as! ActivityCell
			let target = targets[indexPath.row]
			cell.distanceLabel.text = target.name
			var parameterCount = 0
			// Addiere 1 für jeden gegeben Parameter ‘parameterCount‘
			if target.distance != 0 { parameterCount += 1 }
			if target.duration != 0 { parameterCount += 1 }
			if target.pace != 0 { parameterCount += 1 }
			if target.location != nil { parameterCount += 1 }
			
			cell.durationLabel.text = "\(parameterCount) Stück"
			return cell
			
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if segmentControl.selectedSegmentIndex == 0 {
			let section = filteredRuns[section]
			let date = section.date
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMMM yyyy"
			return dateFormatter.string(from: date)
		} else {
			return ""
		}
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selIndex = indexPath
		if segmentControl.selectedSegmentIndex == 0 {
			self.performSegue(withIdentifier: .runDetails, sender: nil)
		} else {
			self.performSegue(withIdentifier: .targetDetails, sender: nil)
		}
	}
	
	@available(iOS 13.0, *)
	override func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint)
	-> UIContextMenuConfiguration? {
		
		selIndex = indexPath
		
		let identifier = "\(String(describing: index))" as NSString
		
		if segmentControl.selectedSegmentIndex == 0 {
			return UIContextMenuConfiguration(
				identifier: identifier,
				previewProvider: nil) { _ in
				
				var actions : [UIAction] = []
				
				// add „More"-Action
				actions.append(UIAction(
					title: "Mehr...",
					image: UIImage(systemName: "")) { _ in
					self.performSegue(withIdentifier: .runDetails, sender: nil)
				})
					
				// Füge die „Bearbeiten"-Action hinzu
				actions.append(UIAction(
					title: "Bearbeiten",
					image: UIImage(systemName: "")) { _ in
					self.performSegue(withIdentifier: .editRun, sender: nil)
				})
					
				
				// Füge die „Show Map"-Action hinzu, wenn auf ‘selectedRun‘ Locations gespeichert sind
				let object = self.filteredRuns[indexPath.section].rows[indexPath.row] as! ObjectRowRun
				if self.hasLocations(for: object.run) {
					actions.append(UIAction(
						title: "Karte ansehen",
						image: UIImage(systemName: "map")) { _ in
						self.performSegue(withIdentifier: .contextMap, sender: nil)
					})
				}
					
				// add „Share Banner"-Action
				actions.append(UIAction(
					title: "Banner teilen",
					image: UIImage(systemName: "square.and.arrow.up")) { _ in
						
					let object = self.filteredRuns[indexPath.section].rows[indexPath.row] as! ObjectRowRun
				
					let imageToShare = [ RunBanner.standard(for: object.run) ]
					let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
					activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
					self.present(activityViewController, animated: true, completion: nil)
				})
					
				// add „Create Banner"-Action
				actions.append(UIAction(
					title: "Banner erstellen",
					image: UIImage(systemName: "plus")) { _ in
						
					self.performSegue(withIdentifier: .createBanner, sender: nil)
				})
					
				// add „Delete"-Action
				actions.append(UIAction(
					title: "Löschen",
					image: UIImage(systemName: "trash"),
					attributes: .destructive) { _ in
					let object = self.filteredRuns[indexPath.section].rows[indexPath.row] as! ObjectRowRun
					CoreDataStack.shared.managedObjectContext.delete(object.run)
					self.filteredRuns[indexPath.section].rows.remove(at: indexPath.row)
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
					self.refresh()
				})
					
				return UIMenu(title: "", image: UIImage(named: ""), children: actions)
			}
		} else {
			return UIContextMenuConfiguration(
				   identifier: identifier,
				   previewProvider: nil) { _ in
				   
				   var actions : [UIAction] = []
				   
				   // Füge die „Mehr..."-Aktion hinzu
				   actions.append(UIAction(
					   title: "Mehr...",
					   image: UIImage(systemName: "")) { _ in
					   self.performSegue(withIdentifier: .targetDetails, sender: nil)
				   })
				   
				   // Füge die „Bearbeiten"-Aktion hinzu
				   actions.append(UIAction(
					   title: "Bearbeiten",
					   image: UIImage(systemName: "")) { _ in
					   self.performSegue(withIdentifier: .editTarget, sender: nil)
				   })
				   
				   // Füge die „Löschen"-Aktion hinzu
				   actions.append(UIAction(
					   title: "Löschen",
					   image: UIImage(systemName: "trash"),
					   attributes: .destructive) { _ in
					   CoreDataStack.shared.managedObjectContext.delete(self.targets[indexPath.row])
					   self.targets.remove(at: indexPath.row)
					   self.tableView.deleteRows(at: [indexPath], with: .automatic)
					   self.refresh()
				   })
					   
				   return UIMenu(title: "", image: UIImage(named: ""), children: actions)
			   }
		   }
	}
		
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if segmentControl.selectedSegmentIndex == 0 {
			if editingStyle == .delete {
				let object = self.filteredRuns[indexPath.section].rows[indexPath.row] as! ObjectRowRun
				CoreDataStack.shared.managedObjectContext.delete(object.run)
				self.filteredRuns[indexPath.section].rows.remove(at: indexPath.row)
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
				self.refresh()
			}
		} else {
			if editingStyle == .delete {
				let target = self.targets[indexPath.row]
				CoreDataStack.shared.managedObjectContext.delete(target)
				self.targets.remove(at: indexPath.row)
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
				self.refresh()
			}
		}
	}
	
	func hasLocations(for run: Run) -> Bool {
		guard
			let locations = run.locations,
			locations.count > 0
		else {
			return false
		}
		return true
	}
}

























/*
	  MARK: PAST RUNS TABLE - NAVIGATION
 
	-sequeIdentifier
	-prepare

*/

extension Activities: SegueHandlerType {
	enum SegueIdentifier: String {
		case runDetails = "PastRunDetailsSeque"
		case contextMap = "ContextMapSeque"
		case createBanner = "CustomRunBannerSeque"
		case createRun = "CreateRunSeque"
		case editRun = "LastRunsEditRun"
		
		case createTarget = "NewBadgeSegue"
		case targetDetails = "BadgeDetailsSegue"
		case editTarget = "EditBadgeSegue"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
			
			// Vorbereitung beim Zeigen vom den Lauf-Details
			case .runDetails:
				let destination = segue.destination as! LastRunsDetails
				let object = self.filteredRuns[self.selIndex.section].rows[self.selIndex.row] as! ObjectRowRun
				destination.currentRun = object.run
				destination.index = object.index
				
			// Vorbereitung beim Zeigen vom der Lauf-Strecke
			case .contextMap:
				let destination = segue.destination as! PastRunMap
				let object = self.filteredRuns[self.selIndex.section].rows[self.selIndex.row] as! ObjectRowRun
				destination.currentRun = object.run
				
			// Vorbereitung beim Zeigen vom Zeigen vom Erstellen eines neuen Lauf-Banners
			case .createBanner:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as? CreateBanner
				let object = self.filteredRuns[self.selIndex.section].rows[self.selIndex.row] as! ObjectRowRun
				viewController!.createBannerType = .run
				viewController!.standardTextLayers = CreateBanner.runLayers(for: object.run)
				
			// Vorbereitung beim Zeigen vom manuellen Erstellen eines neuen Laufes
			case .createRun:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as! CreateRun
				viewController.editingStyle = .new
				viewController.delegate = self
				
			// Vorbereitung zum Zeigen vom Zeigen vom Bearbeiten des ausgewählten Laufes
			case .editRun:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as! CreateRun
				let object = self.filteredRuns[self.selIndex.section].rows[self.selIndex.row] as! ObjectRowRun
				viewController.run = object.run
				viewController.editingStyle = .edit
				viewController.index = object.index
				
				
				
			case .createTarget:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as! CreateTarget
				viewController.editingStyle = .new
				viewController.indexPath = selIndex
				
			case .targetDetails:
				let destination = segue.destination as! BadgeDetails
				let target = targets[selIndex.row]
				destination.currentTarget = target
				destination.indexPath = selIndex
				
			case .editTarget:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as! CreateTarget
				viewController.editingStyle = .edit
				viewController.indexPath = selIndex
				
		}
	}
}
