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

class ChartCell: UITableViewCell {
	
	@IBOutlet weak var stackView: UIStackView!
}








class Successes: UITableViewController {

	var stats: [ObjectRowData] = []
	var sections = [Object]()
	
	var distanceImage: UIImage?
	var durationImage: UIImage?
	var monthImage: UIImage?
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadRecords()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		loadRecords()
	}
	
	
	
	func loadRecords() {
		
		// Konvertiere die Gesamtdistanz und Gesamtzeit zu String
		let formattedDistance = FormatDisplay.distance.from(SuccessStack.totalDistance)
		let formattedDuration = FormatDisplay.duration.from(SuccessStack.totalDuration)
		let formattedAveragePace = SuccessStack.averagePace.cropTo(sequences: 1)
		let formattedAverageDistance = FormatDisplay.distance.from(SuccessStack.averageDistance)
		let formattedAverageDuration = FormatDisplay.duration.from(SuccessStack.averageDuration)
		let formattedAvergateSteps = FormatDisplay.steps.from(SuccessStack.averageSteps)
		let formattedSteps = FormatDisplay.steps.from(SuccessStack.totalSteps)
		
		// Füge alle Erfolge zu der Liste hinzu
		sections = []
		stats = []
		stats.append(ObjectRowData(name: "Gesamtzeit", value: formattedDuration, iconName: "timer"))
		stats.append(ObjectRowData(name: "\u{2300} Zeit", value: formattedAverageDuration, iconName: "timer"))
		stats.append(ObjectRowData(name: "Gesamtdistanz", value: formattedDistance, iconName: "location.north.line"))
		stats.append(ObjectRowData(name: "\u{2300} Distanz", value: formattedAverageDistance, iconName: "location.north.line"))
		stats.append(ObjectRowData(name: "Schritte", value: formattedSteps, iconName: "9.circle"))
		stats.append(ObjectRowData(name: "\u{2300} Schritte", value: formattedAvergateSteps, iconName: "6.circle"))
		stats.append(ObjectRowData(name: "Pace min/km", value: formattedAveragePace, iconName: "speedometer"))
		
		sections.append(Object(name: "", objects: stats, .data))
		sections.append(Object(name: "Vergleich \(FormatDisplay.date.from(date: Date(), "YYYY"))", objects: [ObjectRow()], .chartMonth))
		sections.append(Object(name: "Distanzen", objects: [ObjectRow()], .chartDistance))
		sections.append(Object(name: "Zeiten", objects: [ObjectRow()], .chartDuration))
	}
	
	
   
	
	
	@IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
		self.performSegue(withIdentifier: .settings, sender: nil)
	}
}














/*

	MARK: SUCCESSES - TABLEVIEW

	-numberOfRowsInSection
	-titleForHeaderInSection
	-cellForRowAt
	-contextMenuConfigurationForRowAt

*/

extension Successes {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].objects.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].name
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let section = sections[indexPath.section]
		
		if section.kind == .data {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "SuccessesCell", for: indexPath) as! SuccessesCell
			let object = section.objects[indexPath.row] as! ObjectRowData
			cell.titleView.text = object.name
			cell.valueView.text = String(object.value)
			cell.iconView.image = UIImage(systemName: object.icon)
			
			return cell
			
			
			
			
		} else if section.kind == .chartMonth {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "ChartsCell", for: indexPath) as! ChartCell
			cell.stackView = SuccessStack.monthChart(for: cell)
			
			// Erstelle ein Bild aus den Diagramdaten
			self.monthImage = SuccessStack.monthChartImage(for: cell)
			
			return cell
			
			
			
			
		} else if section.kind == .chartDistance {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "ChartsCell", for: indexPath) as! ChartCell
			cell.stackView = SuccessStack.chart(from: .distance, for: cell)
			
			// Erstelle ein Bild aus den Diagramdaten
			self.distanceImage = SuccessStack.chartImage(from: .distance, for: cell)
						
			return cell
			
			
			
			
		} else if section.kind == .chartDuration {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "ChartsCell", for: indexPath) as! ChartCell
			cell.stackView = SuccessStack.chart(from: .duration, for: cell)
			
			// Erstelle ein Bild aus den Diagramdaten
			self.durationImage = SuccessStack.chartImage(from: .duration, for: cell)
			
			return cell
			
			
			
		} else {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "ChartsCell", for: indexPath) as! ChartCell
			return cell
		}
	}
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		let identifier = "\(String(describing: index))" as NSString
		let section = sections[indexPath.section]
				
		return UIContextMenuConfiguration(
			identifier: identifier,
			previewProvider: nil) { _ in
			
			var actions : [UIAction] = []
			
			if section.kind == .chartMonth {
				
				// add „Share"-Action
				actions.append(UIAction(
					title: "Teilen",
					image: UIImage(systemName: "square.and.arrow.up")) { _ in
					
					let image = self.monthImage!.imageWithInset(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
					let infos = section.name
									
					let imageToShare = [ image, infos as Any ] as [Any]
					let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
					activityViewController.popoverPresentationController?.sourceView = self.view
					self.present(activityViewController, animated: true, completion: nil)
				})
				
				
				
			} else if section.kind == .chartDistance {
								
				// add „Share"-Action
				actions.append(UIAction(
					title: "Teilen",
					image: UIImage(systemName: "square.and.arrow.up")) { _ in
					
					let image = self.distanceImage!.imageWithInset(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
					let infos = section.name
									
					let imageToShare = [ image, infos as Any ] as [Any]
					let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
					activityViewController.popoverPresentationController?.sourceView = self.view
					self.present(activityViewController, animated: true, completion: nil)
				})
				
				
			
			} else if section.kind == .chartDuration {
				
	
				// add „Share"-Action
				actions.append(UIAction(
					title: "Teilen",
					image: UIImage(systemName: "square.and.arrow.up")) { _ in
					
					let image = self.durationImage!.imageWithInset(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
					let infos = section.name
									
					let imageToShare = [ image, infos as Any ] as [Any]
					let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
					activityViewController.popoverPresentationController?.sourceView = self.view
					self.present(activityViewController, animated: true, completion: nil)
				})
				
			}
			
			return UIMenu(title: "", image: UIImage(named: ""), children: actions)
		}
	}
}


































/*

	MARK: SUCCESSES - NAVIGATION

	-segueIdentifier
	-prepare

*/

extension Successes: SegueHandlerType {
	
	enum SegueIdentifier: String {
		case settings = "SettingsSegue"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
			case .settings:
				_ = segue.destination as! Settings
		}
	}
}



























/*

	MARK: SUCCESSES - CHARTS

	-segueIdentifier
	-prepare

*/

extension SuccessStack {
	
	static func chartImage(from parameter: RunParameter, for cell: ChartCell) -> UIImage {
		return chart(from: parameter, for: cell).asImage()
	}
	
	static func chart(from parameter: RunParameter, for cell: ChartCell) -> UIStackView {
		
		// Lösche alle ‘arrangedSubviews‘ vom ‘stackView‘, um neue hinzu zu fügen
		cell.stackView.removeAllArrangedSubviews()
		cell.stackView.distribution = .fillEqually
		cell.stackView.alignment = .bottom
				
		// Lade die Läufe sortiert nach Distanz
		let runs = CoreDataStack.loadRunsSorted(by: parameter)
		
		// Berechne den längsten Lauf und die Relation dazu
		// Lade die Läufe sortiert nach Datum
		var highest = 140.0
		if runs.count > 0 {
			switch parameter {
				case .distance: highest = runs[0].distance
				case .duration: highest = runs[0].duration
					
				default:
					break
			}
		}
		let relation = Double(140/highest)
		let compileRuns = CoreDataStack.loadRunsSorted(by: .date)
		
		
		
		for (index, run) in compileRuns.enumerated() {
			
			if index < 6 {
				
				// Erstelle einen neuen Datensatz(Spalte in dem Diagramm) als UIStackView
				let stackView = UIStackView()
				
				// Ertstelle ein abgrundetes Rechteck für die grafische Darstellung
				let roundedRectangle = UIView()
				var height: CGFloat = 0
				switch parameter {
					case .distance: height = CGFloat(run.distance*relation)
					case .duration: height = CGFloat(run.duration*relation)
						
					default:
						break
				}
				if height < 16 {
					height = 16
				}
				roundedRectangle.height(constant: height)
				roundedRectangle.backgroundColor = .systemBlue
				roundedRectangle.layer.cornerRadius = 8

				
				// Erstelle ein UILabel für die Zeit bzw. die Distanz
				let rowsCountText = UILabel()
				switch parameter {
					case .distance: rowsCountText.text = FormatDisplay.distance.from(run.distance)
					case .duration: rowsCountText.text = FormatDisplay.duration.from(run.duration)
				
					default:
						break
				}
				rowsCountText.textAlignment = .center
				rowsCountText.font = UIFont(name: "Arial", size: 12)
			
				
				// Erstelle ein UILabel für die Initialien des Monats
				let monthText = UILabel()
				monthText.text = Date.monthInitial(from: run.date!.month)
				monthText.textAlignment = .center
				monthText.textColor = .darkGray
				
				// Füge die verschiedenen Teile eines Diagramm-Datensatzes hinzu
				stackView.axis = .vertical
				stackView.spacing = 5
				stackView.addArrangedSubview(rowsCountText)
				stackView.addArrangedSubview(roundedRectangle)
				stackView.addArrangedSubview(monthText)
				
				// Füge den Datensatz zum Diagramm hinzu
				cell.stackView.addArrangedSubview(stackView)
			}
		}
		
		return cell.stackView
	}
	
	
	static func monthChartImage(for cell: ChartCell) -> UIImage {
		return monthChart(for: cell).asImage()
	}
	
	
	static func monthChart(for cell: ChartCell) -> UIStackView {
		
		// Lösche alle ‘arrangedSubviews‘ vom ‘stackView‘, um neue hinzu zu fügen
		cell.stackView.removeAllArrangedSubviews()
		cell.stackView.distribution = .fillEqually
		cell.stackView.alignment = .bottom
		
		// Lade die Läufe
		let runs = CoreDataStack.loadRuns()
		// Gruppiere sie nach Monaten und sortiere sie nach Datum
		var filteredRuns = GroupSections.groupInMonths(runs)
		filteredRuns.sort(by: { lhs, rhs in lhs.rows.count > rhs.rows.count })
		
		// Berechne den Monat mit den meisten Läufen und die Relation dazu
		var highest = filteredRuns.first?.rows.count
		if highest == 0 {
			highest = 1
		}
		let relation = Int(140/highest!)
		filteredRuns.sort { lhs, rhs in lhs.month < rhs.month }
		
		
		for (index, month) in filteredRuns.enumerated() {
			
			if index < 12 {
				let roundedRectangle = UIView()
				var height = CGFloat(month.rows.count*relation)
				if height == 0 {
					height = 16
				}
				roundedRectangle.height(constant: height)
				roundedRectangle.backgroundColor = .systemBlue
				roundedRectangle.layer.cornerRadius = 8
				
				let stackView = UIStackView()
				
				let rowsCountText = UILabel()
				rowsCountText.text = String(month.rows.count)
				rowsCountText.textAlignment = .center
				rowsCountText.font = UIFont(name: "Arial", size: 12)
				
				
				let monthText = UILabel()
				monthText.text = Date.monthInitial(from: month.month)
				monthText.textAlignment = .center
				if Date().month == month.month {
					monthText.textColor = .darkGray
				} else {
					monthText.textColor = .lightGray
				}
				
				
				stackView.axis = .vertical
				stackView.spacing = 5
				stackView.addArrangedSubview(rowsCountText)
				stackView.addArrangedSubview(roundedRectangle)
				stackView.addArrangedSubview(monthText)
				
				cell.stackView.addArrangedSubview(stackView)
			}
		}
					
		return cell.stackView
	}
}
