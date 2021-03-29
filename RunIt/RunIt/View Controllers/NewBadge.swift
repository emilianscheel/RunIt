/**
*
*  NewGoal.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit














class NewBadgeController: UINavigationController {  }

class NewBadge: UITableViewController {
	
	enum EditingStyle {
		case new
		case edit
	}
	
	@IBOutlet weak var backButton: UIBarButtonItem!
	@IBOutlet weak var locationButton: UIButton!
	
	@IBOutlet weak var durationTextField: UITextField!
	@IBOutlet weak var distanceTextField: UITextField!
	@IBOutlet weak var paceTextField: UITextField!
	@IBOutlet weak var nameTextField: UITextField!
	
	var durationPicker = CustomPickerDelegate()
	var distancePicker = CustomPickerDelegate()
	var pacePicker = CustomPickerDelegate()
	
	
	var editingStyle: EditingStyle!
	var indexPath: IndexPath!
	var targets: [Target] = []
	var currentTarget: Target!
	var location: Location?
	
	var isDismissed: (() -> Void)?
	
	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
				
		targets = CoreDataStack.loadTargets()
		
		// Setze die CustomPicker auf die TextFelder
		setUpDistancePicker()
		setUpDurationPicker()
		setUpPacePicker()
		
		// Ändere den ViewController ‘title‘ auf die verschiedenen Zustände von ‘editingStyle‘
		switch editingStyle {
			case .new:
				// Ändere den Titel vom ViewController auf „Neues Ziel“
				self.title = "Neues Ziel"
				
			case .edit:
				// Ändere den Titel vom ViewController auf „Ziel bearbeiten“
				self.title = "Ziel bearbeiten"
				
				// Setze die InputFelder auf die Daten
				currentTarget = targets[indexPath.row]
				nameTextField.text = currentTarget.name
				paceTextField.text = FormatDisplay.pace.from(currentTarget.duration, currentTarget.distance).cropTo(sequences: 1)
				distanceTextField.text = FormatDisplay.distance.from(currentTarget.distance)
				durationTextField.text = FormatDisplay.duration.from(currentTarget.duration)
				
				location = currentTarget.location
				
			case .none:
				// Ändere den Titel vom ViewController auf „Ziel bearbeiten“
				self.title = "Neues Ziel"
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	@IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
		close()
	}
	
	@IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
		
		// Formatiere die Daten aus den Input-Feldern
		let name = nameTextField.text!
		
		// Formatiere die Distanz
		let km = distancePicker.sections[0].value ?? 0
		let hm = distancePicker.sections[1].value ?? 0
		let m  = distancePicker.sections[2].value ?? 0
		let distance = Double((km*1000)+(hm*100)+(m))
		
		// Formatiere die Zeit
		let hrs = durationPicker.sections[0].value ?? 0
		let min = durationPicker.sections[1].value ?? 0
		let sec = durationPicker.sections[2].value ?? 0
		let duration = Int64((hrs*60*60) + (min*60) + (sec))
		
		// Formatiere Pace min/km
		var pace = pacePicker.sections[0].value
		if pace == nil { pace = Int(FormatDisplay.pace.from(duration, distance)) }
		
		
		
		
		// switch the editingStyle between „new“ and „edit“
		switch editingStyle {
			
			case .new:
				// Erstell ein neues Ziel mit den Daten
				let newTarget = Target(context: CoreDataStack.context)
				newTarget.name = name
				newTarget.distance = distance
				newTarget.duration = duration
				newTarget.location = location
				CoreDataStack.saveContext()
							
			case .edit:
				// Ändere die Daten vom ausgewähltem Ziel
				let editedTarget = self.targets[indexPath.row]
				editedTarget.name = name
			
				
				// Überschreibte ‘distance‘, wenn es verändert wurde
				if distance != 0 {
					editedTarget.distance = distance
				}
				
				// Überschreibte ‘duration‘, wenn es verändert wurde
				if duration != 0 {
					editedTarget.duration = duration
				}
				
				// Überschreibte ‘pace‘, wenn es verändert wurde
				if pace != 0 {
					editedTarget.pace = Double(pace!)
				}
				
				// Überschreibte ‘location‘
				editedTarget.location = location
				// Speichere die Daten in ‘CoreData‘
				CoreDataStack.updateTarget(at: indexPath.row, newRun: editedTarget)
				
			case .none:
				break
		}
		
		// Schließe diesen ‘Modally Presentet‘ ViewController
		close()
	}
	
	func close() {
		ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func doneButton() {
		self.view.endEditing(true)
	}
	
	@IBAction func selectLocationButtonTapped(_ sender: UIButton) {
		self.performSegue(withIdentifier: .selectLocation, sender: nil)
	}
	
	func hasChanged(sections: [CustomPickerSection], outputKind: CustomPickerDelegate.OutputKind) -> Bool {
		switch outputKind {
			case .distance, .duration:
				
				if sections[0].value == nil && sections[1].value == nil && sections[2].value == nil {
					return false
				} else {
					return true
				}
				
			case .pace:
				// Formatiere die Zeit
				if sections[0].value == nil {
					return false
				} else {
					return true
				}
		}
	}
}



















/*

	MARK: NEW BADGE - LOCATION PICKER

	-locationSelected

*/

extension NewBadge: SelectLocationDelegate {
	
	func locationSelected(location: Location) {
		self.location = location
	}
}
























/*

	MARK: NEW BADGE - PICKER

	-setUpDurationPicker
	-setUpDistancePicker
	-setUpPacePicker
	-toolBar

*/

extension NewBadge {
	
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
	func setUpPacePicker() {
		
		var pacePickerSections: [CustomPickerSection] = []
		pacePickerSections.append(CustomPickerSection(range: 30, suffix: " Pace min/km"))
		
		pacePicker.sections = pacePickerSections
		pacePicker.resultView = paceTextField
		pacePicker.outputKind = .pace
		
		// Erstelle ein UIPickerView und überschreibe ‘delegate‘ und ‘dataSource‘ auf distancePicker
		let pickerPace = UIPickerView()
		pickerPace.dataSource = pacePicker
		pickerPace.delegate = pacePicker
		paceTextField.inputView = pickerPace
		paceTextField.inputAccessoryView = toolBar()
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
}






















/*

	MARK: NEW BADGE - NAVIGATION

	-SegueIdentifier
	-prepare

*/

extension NewBadge: SegueHandlerType {
	
	enum SegueIdentifier: String {
		case selectLocation = "SelectLocationSegue"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
			default:
				let destination = segue.destination as? UINavigationController
				let viewController = destination?.viewControllers.first as! SelectLocation
				viewController.location = location
				viewController.delegate = self
		}
	}
}
