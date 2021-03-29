/**
*
*  CreateRun.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import UIKit
import CoreData
import CoreLocation
import AVFoundation
import Foundation
import WidgetKit










protocol CreateRunDelegate {
	func didFinishedCreating(run: Run?)
}

class CreateRun: UITableViewController {
	
	enum EditingStyle {
		case new
		case edit
	}
	
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var durationTextField: UITextField!
	@IBOutlet weak var distanceTextField: UITextField!
	@IBOutlet weak var allNotesTextField: UITextField!
	@IBOutlet weak var startersTextField: UITextField!
	@IBOutlet weak var addButton: UIButton!
	
	var hrs: Int = 0
	var min: Int = 0
	var sec: Int = 0
	
	var datePicker = UIDatePicker()
	var startersPicker = UIDatePicker()
	var distancePicker = CustomPickerDelegate()
	var durationPicker = CustomPickerDelegate()
	
	var run: Run?
	var editingStyle: EditingStyle?
	var index: Int?
	var delegate: CreateRunDelegate?
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Füge dem ‘addButton‘ runde Ecken hinzu
		addButton.withCorners(cornerRadius: 16)
		
		switch editingStyle {
			
			// Erstelle einen neuen Lauf
			case .new:
				
				self.title = "Lauf hinzufügen"
				
				setUpDatePicker()
				setUpStartersPicker()
				setUpDistancePicker()
				setUpDurationPicker()
				
			case .edit:
				
				self.title = "Lauf bearbeiten"
				
				// Erstelle ein DateFormatter für die Startzeit
				let timeFormatter = DateFormatter()
				timeFormatter.dateFormat = "HH:mm"
				
				// Erstelle ein DateFormatter für das Datum
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "dd. MMMM yyyy"
				
				let formattedDistance = FormatDisplay.distance.from(run!.distance)
				let formattedDuration = FormatDisplay.duration.from(run!.duration)
				let formattedStarters = timeFormatter.string(from: run!.date!)
				let formattedDate = dateFormatter.string(from: run!.date!)
				
				distanceTextField.text = formattedDistance
				durationTextField.text = formattedDuration
				startersTextField.text = formattedStarters
				dateTextField.text = formattedDate
				
				setUpDatePicker()
				setUpStartersPicker()
				setUpDistancePicker()
				setUpDurationPicker()
		
			case .none:
				break
		}
	}
	
	
	
	
	@IBAction func backTapped(_ sender: UIButton) {
		delegate?.didFinishedCreating(run: nil)
		self.dismiss(animated: true, completion: nil)
	}
	@IBAction func saveTapped(_ sender: UIButton) {
		
		// Falls alle Felder ausgefüllt sind, speicher den Lauf und beende den ViewController
		if dateTextField.text != "" && durationTextField.text != "" && distanceTextField.text != "" && startersTextField.text != ""  {
			saveRun()
			delegate?.didFinishedCreating(run: nil)
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	
	
	@objc func updateDateTextField() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd. MMMM yyyy"
		self.dateTextField.text = dateFormatter.string(from: datePicker.date)
	}
	
	@objc func updateStartTimeField() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		self.startersTextField.text = dateFormatter.string(from: startersPicker.date)
	}
	
	@objc func doneButton() {
		self.view.endEditing(true)
	}
	
	
	
	
	
	@available(iOS 13.4, *)
	func setUpDistancePicker() {
		
		var distancePickerSections: [CustomPickerSection] = []
		distancePickerSections.append(CustomPickerSection(range: 1000, suffix: " km"))
		distancePickerSections.append(CustomPickerSection(range: 100, suffix: " hm"))
		distancePickerSections.append(CustomPickerSection(range: 220, suffix: " m"))
		
		distancePicker.sections = distancePickerSections
		distancePicker.resultView = distanceTextField
		distancePicker.outputKind = .distance
		
		// Erstelle ein UIPickerView und überschreibe ‘delegate‘ und ‘dataSource‘ auf distancePicker
		let pickerDistance = UIPickerView()
		pickerDistance.dataSource = distancePicker
		pickerDistance.delegate = distancePicker
		distanceTextField.inputView = pickerDistance
		distanceTextField.inputAccessoryView = toolBar()
	}
	
	@available(iOS 13.4, *)
	func setUpDurationPicker() {
		
		var durationPickerSections: [CustomPickerSection] = []
		durationPickerSections.append(CustomPickerSection(range: 73, suffix: " h"))
		durationPickerSections.append(CustomPickerSection(range: 60, suffix: " min"))
		durationPickerSections.append(CustomPickerSection(range: 60, suffix: " s"))
		
		durationPicker.sections = durationPickerSections
		durationPicker.resultView = durationTextField
		durationPicker.outputKind = .duration
		
		// Ertelle ein UIPickerView und überschreibe ‘delegate‘ und ‘dataSource‘ auf durationPicker
		let pickerDuration = UIPickerView()
		pickerDuration.dataSource = durationPicker
		pickerDuration.delegate = durationPicker
		durationTextField.inputView = pickerDuration
		durationTextField.inputAccessoryView = toolBar()
	}
	
	@available(iOS 13.4, *)
	func setUpStartersPicker() {
				
		// Up-Date startersPicker und setze ‘datePickerMode‘ zu ‘time‘
		startersPicker.addTarget(self, action: #selector(updateStartTimeField), for: .valueChanged)
		startersPicker.preferredDatePickerStyle = .wheels
		startersPicker.datePickerMode = .time
		startersTextField.inputView = startersPicker
		startersTextField.inputAccessoryView = toolBar()
	}
	
	@available(iOS 13.4, *)
	func setUpDatePicker() {
		
		// Up-Date datePicker und setze ‘datePickerMode‘ zu ‘date‘
		datePicker.addTarget(self, action: #selector(updateDateTextField), for: .valueChanged)
		datePicker.preferredDatePickerStyle = .wheels
		datePicker.datePickerMode = .date
		self.dateTextField.inputView = datePicker
		self.dateTextField.inputAccessoryView = toolBar()
	}
	
	
	
		
	
	func toolBar() -> UIToolbar {
		
		// Erstelle eine UIToolbar und überschreibe Parameter
		let toolBar = UIToolbar()
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = true
		toolBar.sizeToFit()

		// Erstelle die Aktionen für die ToolBar
		let doneButton = UIBarButtonItem(title: "Fertig", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButton))
		let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
		toolBar.setItems([spacer, doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		return toolBar
	}

	
	
	
	
	
	
	
	// MARK: - saveRun
	
	private func saveRun() {
		
		let context = CoreDataStack.shared.workingContext
		
		switch editingStyle {
			case .new:
				
				// Erstelle ein DateFormatter und überschreibe das ‘dateFormat‘
				let formatter = DateFormatter()
				formatter.dateFormat = "dd. MMMM yyyy HH:mm"
				
				// Erstelle den neuen Lauf
				let newRun = Run(context: context)
				
				// Formatiere die Distanz
				let km = distancePicker.sections[0].value ?? 0
				let hm = distancePicker.sections[1].value ?? 0
				let m  = distancePicker.sections[2].value ?? 0
				
				// Formatiere die Zeit
				let hrs = durationPicker.sections[0].value ?? 0
				let min = durationPicker.sections[1].value ?? 0
				let sec = durationPicker.sections[2].value ?? 0
				
				// Überschreibe die Parameter
				newRun.distance = Double((km*1000)+(hm*100)+(m))
				newRun.duration = Double((hrs*60*60) + (min*60) + (sec))
				newRun.date = formatter.date(from: self.dateTextField.text! + " " + self.startersTextField.text!)
				newRun.notes = allNotesTextField.text
				
				// Speicher den CoreData-Context -> Speicher den neuen Lauf
				CoreDataStack.shared.saveWorkingContext(context: context)
				WidgetCenter.shared.reloadAllTimelines()
				
				self.run = newRun
				
				
			case .edit:
				
				// Erstelle ein DateFormatter und überschreibe das ‘dateFormat‘
				let formatter = DateFormatter()
				formatter.dateFormat = "dd. MMMM yyyy HH:mm"
				
				// Formatiere die Distanz, wenn die Distanz 0 beträgt, dann nehem diese vom vorherigen Lauf
				let km = distancePicker.sections[0].value ?? 0
				let hm = distancePicker.sections[1].value ?? 0
				let m  = distancePicker.sections[2].value ?? 0
				var distance = Double((km*1000)+(hm*100)+(m))
				if distance == 0 {
					distance = run!.distance
				}
				
				// Formatiere die Zeit, wenn die Zeit 0 beträgt, dann nehme diese vom vorherigen Lauf
				let hrs = durationPicker.sections[0].value ?? 0
				let min = durationPicker.sections[1].value ?? 0
				let sec = durationPicker.sections[2].value ?? 0
				var duration = Double((hrs*60*60) + (min*60) + (sec))
				if duration == 0 {
					duration = run!.duration
				}
				
				// Überschreibe die Parameter
				run!.distance = distance
				run!.duration = duration
				run!.date = formatter.date(from: self.dateTextField.text! + " " + self.startersTextField.text!)
				run!.notes = allNotesTextField.text
				
				CoreDataStack.updateRun(at: index ?? 0, newRun: run!)
				
				// Speicher den CoreData-Context -> Speicher den neuen Lauf
				CoreDataStack.shared.saveWorkingContext(context: context)
				
				
			case .none:
				break
		}
	}
}
