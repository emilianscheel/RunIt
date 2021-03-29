
/**
 *
 *  CustomPicker.swift
 *  RunIt
 *
 *  Created by Emilian Scheel on 09.02.21
 *
 */








import Foundation
import UIKit

class CustomPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
	
	enum OutputKind {
		case distance
		case duration
		case pace
	}
	
	var sections: [CustomPickerSection] = []
	var resultView: UITextField?
	var appSettingsKey: AppSettings.key?
	var outputKind: OutputKind?
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return sections.count
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return sections[component].range
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return sections[component].präfix + String(row) + sections[component].suffix
	}
	
	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		if sections[component].width != 0 {
			return sections[component].width!
		} else {
			return CGFloat(Int(pickerView.bounds.width)/sections.count)
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		sections[component].value = row
		
		resultView?.text = ""
		
		setOutputKind()
		setAppSettings(for: row)
	}
	
	func setOutputKind() {
		guard outputKind != nil else {
			for section in sections {
				resultView?.text! += section.präfix + String(section.value ?? 0) + section.suffix
			}
			return
		}
		
		switch outputKind {
			case .distance:
				// Formatiere die Distanz
				let km = sections[0].value ?? 0
				let hm = sections[1].value ?? 0
				let m  = sections[2].value ?? 0
				
				// Überschreibe die Parameter
				let distance = Double((km*1000)+(hm*100)+(m))
				resultView?.text! += FormatDisplay.distance.from(distance)
				
			case .duration:
				// Formatiere die Zeit
				let hrs = sections[0].value ?? 0
				let min = sections[1].value ?? 0
				let sec = sections[2].value ?? 0
				let duration = Double((hrs*60*60) + (min*60) + (sec))
				resultView?.text! += FormatDisplay.duration.from(duration)
				
			case .pace:
				// Formatiere die Zeit
				let pace = sections[0].value ?? 0
				resultView?.text! += FormatDisplay.pace.from(pace).cropTo(sequences: 1)
				
			case .none:
				break
		}
	}
	
	func setAppSettings(for row: Int) {
		guard appSettingsKey != nil else {
			return
		}
		
		AppSettings[appSettingsKey!] = row
	}
}



struct CustomPickerSection {
	var range: Int
	var suffix: String
	var präfix: String
	var value: Int?
	var width: CGFloat?
	
	init(range: Int, suffix: String = "", präfix: String = "", width: CGFloat = 0, value: Int = 0) {
		self.range = range
		self.suffix = suffix
		self.präfix = präfix
		self.width = width
		self.value = value
	}
}















class LayerValuePicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
	
	var data: [RunBanner.TextLayer] = []
	var textField: UITextField?
	var value: String = ""
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return data.count
	}

	func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return data[row].text
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		value = data[row].text
		textField!.text = value
	}
}

class LayerPositionPicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
	
	var data: [RunBanner.LayerPosition] = []
	var textField: UITextField?
	var value: RunBanner.LayerPosition = .center
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return data.count
	}

	func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return data[row].rawValue
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		value = data[row]
		textField!.text = value.rawValue
	}
}
