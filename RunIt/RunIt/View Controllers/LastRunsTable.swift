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











class PastRunsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
}


















class PastRunsTable: UITableViewController, ModalTransitionListener {
	
	
	
	@IBOutlet weak var btnEdit: UIBarButtonItem!
	@IBOutlet weak var btnAddManually: UIBarButtonItem!
	
	var runs: [Run] = []
	var filteredRuns = [GroupSections.Object]()
	var selIndex: IndexPath = IndexPath(row: 0, section: 0)
	
	
	
	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setzte den Listener für den ModalTransitionMediator zu ‘self‘
		ModalTransitionMediator.instance.setListener(listener: self)
		
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
		self.filteredRuns = GroupSections.group(runs, by: .month)
		self.filteredRuns.sort { lhs, rhs in lhs.date < rhs.date }
		
		// Aktualisiere ‘tableView‘ mit den neuen Daten
		tableView.reloadData()
	}
	
	func popoverDismissed() {
		refresh()
	}
	
	@IBAction func createRunButtonTapped(_ sender: UIBarButtonItem) {
		self.performSegue(withIdentifier: .createRun, sender: nil)
	}
	
	@IBAction func editModeChanged(_ sender: UIBarButtonItem) {
		
		self.navigationItem.searchController!.isActive = !self.navigationItem.searchController!.isActive
		self.navigationItem.searchController!.isEditing = !self.navigationItem.searchController!.isEditing
		self.navigationItem.searchController?.searchBar.setShowsCancelButton(!(self.navigationItem.searchController?.searchBar.showsCancelButton)!, animated: true)
	}
}






















/*
	  MARK: PAST RUNS TABLE - SEARCH
 
	-textDidChange
	-didBeginEditing
	-cancelButtonClicked

 */

extension PastRunsTable: UISearchBarDelegate {
		
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
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


extension PastRunsTable {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if filteredRuns.count == 0 {
			self.tableView.addMessage("Keine letzten Läufe")
		} else {
			self.tableView.restore()
		}
		return filteredRuns.count
	}
		
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let section = filteredRuns[section]
		return section.rows.count
	}
		
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "PastRunsCell", for: indexPath) as! PastRunsTableViewCell
		let sections = self.filteredRuns[indexPath.section]
		let pastRun = sections.rows[indexPath.row] as! ObjectRowRun
				
		cell.distanceLabel.text = FormatDisplay.distance.from(pastRun.run.distance)
		cell.durationLabel.text = FormatDisplay.duration.from(pastRun.run.distance)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = filteredRuns[section]
		let date = section.date
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMMM yyyy"
		return dateFormatter.string(from: date)
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selIndex = indexPath
		self.performSegue(withIdentifier: .details, sender: nil)
	}
	
	@available(iOS 13.0, *)
	override func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint)
	-> UIContextMenuConfiguration? {
		
		selIndex = indexPath
		
		let identifier = "\(String(describing: index))" as NSString
		
		return UIContextMenuConfiguration(
			identifier: identifier,
			previewProvider: nil) { _ in
			
			var actions : [UIAction] = []
			
			// add „More"-Action
			actions.append(UIAction(
				title: "Mehr...",
				image: UIImage(systemName: "")) { _ in
				self.performSegue(withIdentifier: .details, sender: nil)
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
				CoreDataStack.context.delete(object.run)
				self.filteredRuns[indexPath.section].rows.remove(at: indexPath.row)
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
				self.refresh()
			})
				
			return UIMenu(title: "", image: UIImage(named: ""), children: actions)
		}
	}
		
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let object = self.filteredRuns[indexPath.section].rows[indexPath.row] as! ObjectRowRun
			CoreDataStack.context.delete(object.run)
			self.filteredRuns[indexPath.section].rows.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.refresh()
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

extension PastRunsTable: SegueHandlerType {
	enum SegueIdentifier: String {
		case details = "PastRunDetailsSeque"
		case contextMap = "ContextMapSeque"
		case createBanner = "CustomRunBannerSeque"
		case createRun = "CreateRunSeque"
		case editRun = "LastRunsEditRun"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
			
			// VORBEREITUNG beim Zeigen vom den Lauf-Details.
			case .details:
				let destination = segue.destination as! LastRunsDetails
				let object = self.filteredRuns[self.selIndex.section].rows[self.selIndex.row] as! ObjectRowRun
				destination.currentRun = object.run
				destination.index = object.index
				
			// VORBEREITUNG beim Zeigen vom der Lauf-Strecke.
			case .contextMap:
				let destination = segue.destination as! PastRunMap
				let object = self.filteredRuns[self.selIndex.section].rows[self.selIndex.row] as! ObjectRowRun
				destination.currentRun = object.run
				
			// VORBEREITUNG beim Zeigen vom Zeigen vom Erstellen eines neuen Lauf-Banners.
			case .createBanner:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as? CreateBanner
				let object = self.filteredRuns[self.selIndex.section].rows[self.selIndex.row] as! ObjectRowRun
				viewController!.createBannerType = .run
				viewController!.standardTextLayers = CreateBanner.runLayers(for: object.run)
				
			// VORBEREITUNG beim Zeigen vom manuellen Erstellen eines neuen Laufs.
			case .createRun:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as? CreateRun
				viewController!.editingStyle = .new
				
			case .editRun:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as? CreateRun
				let object = self.filteredRuns[self.selIndex.section].rows[self.selIndex.row] as! ObjectRowRun
				viewController!.run = object.run
				viewController!.editingStyle = .edit
				viewController!.index = object.index
		}
	}
}
