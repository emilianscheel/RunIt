
/**
 *
 *  PersonalSettings.swift
 *  RunIt
 *
 *  Created by Emilian Scheel on 09.02.21
 *
 */

import UIKit












class PersonalSettings: UITableViewController {
	
	@IBOutlet weak var bodyHeightTextField: UITextField!
	@IBOutlet weak var bodyWeightTextField: UITextField!
	@IBOutlet weak var stepWeightTextField: UITextField!
	
	let bodyHeightPicker = CustomPickerDelegate()
	let bodyWeightPicker = CustomPickerDelegate()
	let stepWeightPicker = CustomPickerDelegate()
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		
		
		
		// create bodyHeightSections for picker
		var bodyHeightSections: [CustomPickerSection] = []
		bodyHeightSections.append(CustomPickerSection(range: 220, suffix: " cm"))
		
		// create bodyWeightSections for picker
		var bodyWeightSections: [CustomPickerSection] = []
		bodyWeightSections.append(CustomPickerSection(range: 120, suffix: " kg"))
		
		// create stepWeightSections for picker
		var stepWeightSections: [CustomPickerSection] = []
		stepWeightSections.append(CustomPickerSection(range: 120, suffix: " cm"))
		
		
		
		
		
		// create UIToolBar for textFields inputAccessoryView
		let toolBar = UIToolbar()
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = true
		toolBar.sizeToFit()

		// create toolbars actions
		let doneButton = UIBarButtonItem(title: "Fertig", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButton))
		let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
		toolBar.setItems([spacer, doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		
		
		bodyHeightPicker.sections = bodyHeightSections
		bodyHeightPicker.resultView = bodyHeightTextField
		bodyHeightPicker.appSettingsKey = .user_bodyHeight
		
		bodyWeightPicker.sections = bodyWeightSections
		bodyWeightPicker.resultView = bodyWeightTextField
		bodyWeightPicker.appSettingsKey = .user_bodyWeight
		
		stepWeightPicker.sections = stepWeightSections
		stepWeightPicker.resultView = stepWeightTextField
		stepWeightPicker.appSettingsKey = .user_bodyWeight
		
		
		// set bodyHeightTextFields inputView and inputAccessoryView
		let pickerBodyHeight = UIPickerView()
		pickerBodyHeight.dataSource = bodyHeightPicker
		pickerBodyHeight.delegate = bodyHeightPicker
		bodyHeightTextField.inputView = pickerBodyHeight
		bodyHeightTextField.inputAccessoryView = toolBar
		
		// set bodyWeightTextFields inputView and inputAccessoryView
		let pickerBodyWeight = UIPickerView()
		pickerBodyWeight.dataSource = bodyWeightPicker
		pickerBodyWeight.delegate = bodyWeightPicker
		bodyWeightTextField.inputView = pickerBodyWeight
		bodyWeightTextField.inputAccessoryView = toolBar
		
		// set stepWeightTextFields inputView and inputAccessoryView
		let pickerStepWeight = UIPickerView()
		pickerStepWeight.dataSource = stepWeightPicker
		pickerStepWeight.delegate = stepWeightPicker
		stepWeightTextField.inputView = pickerStepWeight
		stepWeightTextField.inputAccessoryView = toolBar
		
		
		
		
		
		
		// get saved bodyHeight, bodyWeight and stepWeight
		let bodyHeight = AppSettings.intValue(.user_bodyHeight) ?? 0
		let bodyWeight = AppSettings.intValue(.user_bodyWeight) ?? 0
		let stepWeight = AppSettings.intValue(.user_stepWeight) ?? 0
				
		bodyHeightPicker.sections[0].value = bodyHeight
		bodyWeightPicker.sections[0].value = bodyWeight
		stepWeightPicker.sections[0].value = stepWeight
		
		bodyHeightTextField.text = String(bodyHeight) + " cm"
		bodyWeightTextField.text = String(bodyWeight) + " kg"
		stepWeightTextField.text = String(stepWeight) + " cm"
    }
	
	
	@objc func doneButton() {
		self.view.endEditing(true)
		
		AppSettings[.user_bodyHeight] = bodyHeightPicker.sections[0].value
		AppSettings[.user_bodyWeight] = bodyWeightPicker.sections[0].value
		AppSettings[.user_stepWeight] = stepWeightPicker.sections[0].value
	}
	
	@IBAction func bodyHeightTextFieldChanged(_ sender: UITextField) {
	}
	@IBAction func bodyWeightTextFieldChanged(_ sender: UITextField) {
	}
	@IBAction func stepWeightTextFieldChanged(_ sender: UITextField) {
	}
}
