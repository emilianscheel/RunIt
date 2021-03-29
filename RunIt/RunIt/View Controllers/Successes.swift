/**
 *
 *  Successes.swift
 *  RunIt
 *
 *  Created by Emilian Scheel on 09.02.21
 *
 */

import UIKit












class SuccessesCell: UITableViewCell {
	
	@IBOutlet weak var iconView: UIImageView!
	@IBOutlet weak var titleView: UILabel!
	@IBOutlet weak var valueView: UILabel!
}









class Successes: UITableViewController {

	var stats: [ObjectRowDatas] = []
	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadRecords()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		loadRecords()
	}
	
	
   
	func loadRecords() {
		
		// Initialisiere die Variablen für die Erfolge
		var totalDistance: Double = 0 		// Einheit: Meter
		var totalDuration: Double = 0		// Einheit: Sekunden
		var averagePace: Double = 0 		// Einheit: Minuten/Kilometer
		var averageDistance: Double = 0		// Einheit: Meter
		var averageDuration: Double = 0 	// Einheit: Sekunden
		
		// Lade alle Läufe aus dem Speicher
		let runs = CoreDataStack.loadRuns()
		
		// Addiere für jeden Lauf die Distanz und Zeit
		for run in runs {
			totalDistance = totalDistance + run.distance
			totalDuration = totalDuration + Double(run.duration)
			
			// Addiere und konvertiere den Durchschnitts-Pace
			let kilometers = run.distance/1000
			let minutes = run.duration/60
			let pace = Double(minutes) / kilometers
			averagePace += pace
		}
		
		// Formatiere die Durchschnitts-Pace pro Lauf.
		averagePace = averagePace / Double(runs.count)
		// Formatiere die Durchschnitts-Zeit pro Lauf.
		averageDuration = totalDuration / Double(runs.count)
		// Formatiere die Durchschnitts-Distanz pro Lauf.
		averageDistance = totalDistance / Double(runs.count)
		
		// Kontrolliere, ob die Werter auf NaN stehen und setze sie wenn gegeben auf 0
		if averageDistance.isNaN { averageDuration = 0 }
		if averageDuration.isNaN { averageDuration = 0 }
		if totalDistance.isNaN { averageDuration = 0 }
		if totalDuration.isNaN { averageDuration = 0 }
		
		// Konvertiere die Gesamtdistanz und Gesamtzeit zu String
		let formattedDistance = FormatDisplay.distance.from(totalDistance)
		let formattedDuration = FormatDisplay.duration.from(totalDuration)
		let formattedAveragePace = averagePace.cropTo(sequences: 1)
		let formattedAverageDistance = FormatDisplay.distance.from(averageDistance)
		let formattedAverageDuration = FormatDisplay.duration.from(averageDuration)
		
		// Füge alle Erfolge zu der Liste hinzu
		stats = []
		stats.append(ObjectRowDatas(name: "Gesamtzeit", value: formattedDuration, iconName: "timer"))
		stats.append(ObjectRowDatas(name: "Gesamtdistanz", value: formattedDistance, iconName: "location.north.line"))
		stats.append(ObjectRowDatas(name: "Pace min/km", value: formattedAveragePace, iconName: "speedometer"))
		stats.append(ObjectRowDatas(name: "\u{2300} Zeit", value: formattedAverageDuration, iconName: "timer"))
		stats.append(ObjectRowDatas(name: "\u{2300} Distanz", value: formattedAverageDistance, iconName: "location.north.line"))
	}
	
	@IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
		self.performSegue(withIdentifier: .createBanner, sender: nil)
	}
}














/*

	MARK: SUCCESSES - TABLEVIEW

	-numberOfRowsInSection
	-cellForRowAt

*/

extension Successes {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stats.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "SuccessesCell", for: indexPath) as! SuccessesCell
		
		let stat = stats[indexPath.row]
		
		cell.titleView.text = stat.name
		cell.valueView.text = String(stat.value)
		cell.iconView.image = stat.icon
		
		return cell
	}
}






















/*

	MARK: SUCCESSES - NAVIGATION

	-segueIdentifier
	-prepare

*/

extension Successes: SegueHandlerType {
	
	enum SegueIdentifier: String {
		case createBanner = "SuccessesBannerSegue"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
				
			case .createBanner:
				let destination = segue.destination as! UINavigationController
				let viewController = destination.viewControllers.first as? CreateBanner
				viewController?.createBannerType = .success
				viewController?.standardTextLayers = CreateBanner.successLayers(for: stats)
		}
	}
}
