/**
*
*  NewRunPastDetails.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit











class CompareRuns: UIViewController {
	
	@IBOutlet weak var segmentControl: UISegmentedControl!
	@IBOutlet weak var showAllButton: UIBarButtonItem!
	@IBOutlet weak var backButton: UIBarButtonItem!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var earnedLabel: UILabel!
	@IBOutlet weak var noItemsView: UIImageView!
	
	var shownRuns: [Run] = []
	var currentRun: Run!
	var showsAll = false
	
	
	
	
	
	
	// MARK: viewDidLoad
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
		
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	
	
	
	
	
	
	
	
	@IBAction func showAllButtonTapped(_ sender: UIBarButtonItem) {
		if showsAll {
			refresh()
			showAllButton.title = "Mehr"
		} else {
			shownRuns = CoreDataStack.loadRuns()
			showAllButton.title = "Weniger"
		}
		
		shownRuns.sort(by: { $0.distance < $1.distance })
		showsAll = !showsAll
		self.tableView.reloadData()
		
		if shownRuns.count == 0 {
			noItemsView.isHidden = false
		} else {
			noItemsView.isHidden = true
		}
	}
		
	@IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func segmentChanged(_ sender: UISegmentedControl) {
		
		showAllButton.title = "Mehr"
		showsAll = false
		refresh()
	}
	
	@objc func refresh() {
		
		switch segmentControl.selectedSegmentIndex {
			case 0:
				shownRuns = RunExtension.loadRuns(for: currentRun.distance)
			case 1:
				shownRuns = RunExtension.loadRuns(for: currentRun.duration)
			case 2:
				shownRuns = RunExtension.loadRuns(currentRun.duration, currentRun.distance)
			default:
				break
		}
		
		// Setze den Titel
		earnedLabel.text = "Insgesamt " + String(shownRuns.count) + " mal erreicht"
		
		self.tableView.reloadData()
	}
}






























/*
	  MARK: COMPARE RUNS - TABLEVIEW
 
	-numberOfItemsInSection
	-cellForItemAt

 */

extension CompareRuns: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return shownRuns.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "PastRunsDetailCell", for: indexPath)
		let run = shownRuns[indexPath.row]
		
		switch segmentControl.selectedSegmentIndex {
			case 0:
				// Füge die Distanz als zweiten String-Absatz hinzu.
				cell.textLabel?.text = FormatDisplay.distance.from(run.distance)
				
				// Füge „erreicht/nicht erreicht“-Absatz hinzu.
				if currentRun.distance < run.distance  {
					cell.textLabel?.textColor = .label
					cell.textLabel?.text! += " erreicht"
				} else {
					cell.textLabel?.textColor = .systemRed
					cell.textLabel?.text! += " nicht erreicht"
				}
			
			case 1:
				
				// Füge die Distanz als zweiten String-Absatz hinzu.
				cell.textLabel?.text = FormatDisplay.duration.from(run.duration)
				
				// Füge „erreicht/nicht erreicht“-Absatz hinzu.
				if currentRun.duration < run.duration  {
					cell.textLabel?.textColor = .label
					cell.textLabel?.text! += " erreicht"
				} else {
					cell.textLabel?.textColor = .systemRed
					cell.textLabel?.text! += " nicht erreicht"
				}
				
			case 2:
				
				// Füge die Distanz als zweiten String-Absatz hinzu.
				cell.textLabel?.text = FormatDisplay.pace.from(run.duration, run.distance).cropTo(sequences: 1).with(.pace)
				
				// Füge „erreicht/nicht erreicht“-Absatz hinzu.
				if FormatDisplay.pace.from(currentRun.duration, currentRun.distance) < FormatDisplay.pace.from(run.duration, run.distance)  {
					cell.textLabel?.textColor = .label
					cell.textLabel?.text! += " erreicht"
				} else {
					cell.textLabel?.textColor = .systemRed
					cell.textLabel?.text! += " nicht erreicht"
				}
				
			
			default:
				break
		}
		
		// Färbe den Lauf zu Blau, wenn er der aktuelle ist.
		if currentRun == run {
			cell.textLabel?.textColor = .systemBlue
		} else if cell.textLabel?.textColor != .systemRed {
			cell.textLabel?.textColor = .label
		}
		
		return cell
	}
}
