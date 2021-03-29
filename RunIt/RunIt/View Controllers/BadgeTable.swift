/**
*
*  GoalsTable.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit
import CoreData










class BadgeCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var valueLabel: UILabel!
}














class BadgeTable: UITableViewController, UITabBarControllerDelegate, ModalTransitionListener {
	
	@IBOutlet weak var btnEdit: UIBarButtonItem!
	@IBOutlet weak var addButton: UIBarButtonItem!
	
	var selIndex: IndexPath = IndexPath(row: 0, section: 0)
	var targets: [Target] = []
	
	
	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Lade die Daten und up-date die Tabelle
		refresh()
		
		// Setze ModalTransitionMediators ‘listener‘ to ‘self‘
		ModalTransitionMediator.instance.setListener(listener: self)
		
		// Setze SearchBars ‘delegate‘ zu ‘self‘
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
		
		// Zeige die TabBar, wenn der Bildschirm angezeigt wird
		self.tabBarController?.tabBar.isHidden = false
	}
	
	func popoverDismissed() {
		refresh()
		self.navigationController?.dismiss(animated: true, completion: nil)
	}

	@objc func refresh() {

		targets = CoreDataStack.loadTargets()
		
		tableView.reloadData()
	}
	
	@IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
		self.performSegue(withIdentifier: .newGoal, sender: nil)
	}
	
	@IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
		
		self.navigationItem.searchController!.isActive = !self.navigationItem.searchController!.isActive
		self.navigationItem.searchController!.isEditing = !self.navigationItem.searchController!.isEditing
		self.navigationItem.searchController?.searchBar.setShowsCancelButton(!(self.navigationItem.searchController?.searchBar.showsCancelButton)!, animated: true)
	}
}





























/*

	MARK: GOALS TABLE - SEARCHBAR

	-textDidChange
	-didBeginEditing
	-cancelButton

*/

extension BadgeTable: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
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

	MARK: GOALS TABLE - TABLEVIEW

	-numberOfRowsInSection
	-cellForRowAt
	-editinStyle
	-editModeChanged

*/


extension BadgeTable {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if targets.count == 0 { self.tableView.addMessage("Keine Ziele festgelegt") }
		else { self.tableView.restore() }
		return targets.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Lade die UITableView-Zelle und ändere die TextFelder auf die Daten
		let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeCell", for: indexPath) as! BadgeCell
		let target = targets[indexPath.row]
		
		cell.nameLabel.text = target.name

		
		var parameterCount = 0
		
		// Addiere 1 für jeden gegeben Parameter ‘parameterCount‘
		if target.distance != 0 { parameterCount += 1 }
		if target.duration != 0 { parameterCount += 1 }
		if target.pace != 0 { parameterCount += 1 }
		if target.location != nil { parameterCount += 1 }
		
		cell.valueLabel.text = "\(parameterCount) Stück"

		return cell
	}
		
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			CoreDataStack.context.delete(self.targets[indexPath.row])
			self.targets.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.refresh()
		}
	}
	
	@available(iOS 13.0, *)
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		selIndex = indexPath
		let identifier = "\(String(describing: index))" as NSString
		
		return UIContextMenuConfiguration(
			identifier: identifier,
			previewProvider: nil) { _ in
			
			var actions : [UIAction] = []
			
			// Füge die „Mehr..."-Aktion hinzu
			actions.append(UIAction(
				title: "Mehr...",
				image: UIImage(systemName: "")) { _ in
				self.performSegue(withIdentifier: .details, sender: nil)
			})
			
			// Füge die „Bearbeiten"-Aktion hinzu
			actions.append(UIAction(
				title: "Bearbeiten",
				image: UIImage(systemName: "")) { _ in
				self.performSegue(withIdentifier: .editBadge, sender: nil)
			})
			
			// Füge die „Löschen"-Aktion hinzu
			actions.append(UIAction(
				title: "Löschen",
				image: UIImage(systemName: "trash"),
				attributes: .destructive) { _ in
				CoreDataStack.context.delete(self.targets[indexPath.row])
				self.targets.remove(at: indexPath.row)
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
				self.refresh()
			})
				
			return UIMenu(title: "", image: UIImage(named: ""), children: actions)
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selIndex = indexPath
		self.performSegue(withIdentifier: .details, sender: nil)
	}
		
	@IBAction func editModeChanged(_ sender: UIBarButtonItem) {
		if(self.tableView.isEditing == true) {
			self.tableView.setEditing(false, animated: true)
			self.btnEdit.title = "Bearbeiten"
		} else {
			self.tableView.setEditing(true, animated: true)
			self.btnEdit.title = "Fertig"
		}
	}
}




















/*

	MARK: GOALS TABLE - NAVIGATION

	-SegueIdentifier
	-prepare
	-shouldPerformSegue

*/

extension BadgeTable: SegueHandlerType {
	enum SegueIdentifier: String {
		case details = "BadgeDetails"
		case newGoal = "NewBadgeSegue"
		case editBadge = "BadgeTableEditBadge"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
			
			case .details:
				let destination = segue.destination as! BadgeDetails
				let indexPath = tableView.indexPathForSelectedRow!
				let target = targets[indexPath.row]
				destination.currentTarget = target
				destination.indexPath = indexPath
				
			case .newGoal:
				let destination = segue.destination as! NewBadgeController
				let viewController = destination.viewControllers.first as? NewBadge
				viewController?.editingStyle = .new
				viewController?.indexPath = selIndex
				
			case .editBadge:
				let destination = segue.destination as! NewBadgeController
				let viewController = destination.viewControllers.first as? NewBadge
				viewController?.editingStyle = .edit
				viewController?.indexPath = selIndex
		}
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		guard let segue = SegueIdentifier(rawValue: identifier) else { return false }
		switch segue {
			
			case .details:
				guard let cell = sender as? UITableViewCell else { return false }
				return cell.accessoryType == .disclosureIndicator
				
			case .newGoal:
				return false
				
			case .editBadge:
				return false
		}
	}
}
