/**
*
*  PopUpSettings.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import UIKit














class PopUpSettings: UITableViewController {

	
	@IBOutlet weak var showNoLocationsSaveAlertSwitch: UISwitch!
	@IBOutlet weak var showNoCameraIsReleasedSwitch: UISwitch!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	func refresh() {
		// Lade ‘showNoLocationsSavedAlert‘ aus den AppSettings und setze es auf das ‘share‘
		showNoLocationsSaveAlertSwitch.isOn = AppSettings.boolValue(.alert_showNoLocationsSaved)
		
		// Lade ‘showNoCameraIsAvailable‘ aus den AppSettings und setze es auf das ‘share‘
		showNoCameraIsReleasedSwitch.isOn = AppSettings.boolValue(.alert_showNoCameraAvailable)
	}
	
	@IBAction func showNoLocationsSavedAlertSwitchChanged(_ sender: UISwitch) {
		AppSettings[.alert_showNoLocationsSaved] = sender.isOn
	}
	
	@IBAction func showNoCameraIsReleasedSwitchChanged(_ sender: UISwitch) {
		AppSettings[.alert_showNoCameraAvailable] = sender.isOn
	}
	
	@IBAction func resetAllTapped(_ sender: UIButton) {
		
		// Setze alle Warnmeldungen zurück und lade neu
		AppSettings[.alert_showNoLocationsSaved] = true
		AppSettings[.alert_showNoCameraAvailable] = true
		
		refresh()
	}
}
