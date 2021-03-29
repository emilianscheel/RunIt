
/**
 *
 *  RunSettings.swift
 *  RunIt
 *
 *  Created by Emilian Scheel on 09.02.21
 *
 */

import UIKit
import Foundation













class RunSettings: UITableViewController {
	
	@IBOutlet weak var gpsLabel: UILabel!
	@IBOutlet weak var gpsStepper: UIStepper!
	@IBOutlet weak var howRecentLabel: UILabel!
	@IBOutlet weak var howRecentStepper: UIStepper!
	@IBOutlet weak var radiusLabel: UILabel!
	@IBOutlet weak var radiusStepper: UIStepper!
	@IBOutlet weak var shareNewRunSwitch: UISwitch!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Lade ‘gpsAccuaracy‘ aus den AppSettings und setze es auf das ‘gpsLabel‘
		gpsStepper.value = AppSettings.doubleValue(.gpsAccuaracy) ?? 20
		gpsLabel.text = String(format: "%.0f", gpsStepper.value)
		
		// Lade ‘howRecent‘ aus den AppSettings und setze es auf das ‘howRecentLabel‘
		howRecentStepper.value = AppSettings.doubleValue(.howRecent) ?? 10
		howRecentLabel.text = String(format: "%.0f", howRecentStepper.value)
		
		// Lade ‘radiusLocation‘ aus den AppSettings und setze es auf das ‘radiusLabel‘
		radiusStepper.value = AppSettings.doubleValue(.locationRadius) ?? 50
		radiusLabel.text = String(format: "%.0f", radiusStepper.value)
		
		// Lade ‘shareNewRun‘ aus den AppSettings und setze es auf das ‘share‘
		shareNewRunSwitch.isOn = AppSettings.boolValue(.shareNewRun)
	}
	

	
	
	
	
	
	
	
	@IBAction func gpsStepperChanged(_ sender: UIStepper) {
		AppSettings[.gpsAccuaracy] = sender.value
		gpsLabel.text = String(format: "%.0f", sender.value)
	}
	
	@IBAction func howRecentStepperChanged(_ sender: UIStepper) {
		AppSettings[.howRecent] = sender.value
		howRecentLabel.text = String(format: "%.0f", sender.value)
	}
	
	@IBAction func radiusStepperChanged(_ sender: UIStepper) {
		AppSettings[.locationRadius] = sender.value
		radiusLabel.text = String(format: "%.0f", sender.value)
	}
	
	@IBAction func shareRunsSwitchChanged(_ sender: UISwitch) {
		AppSettings[.shareNewRun] = sender.isOn
	}
}





























/*

	MARK: RUN SETTINGS - TABLEVIEW

	-didSelectRowAt

*/

extension RunSettings {
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// ZURÜCKSETZEN
		if indexPath.section == 0 && indexPath.row == 3 {
			AppSettings[.gpsAccuaracy] = 20.0
			AppSettings[.howRecent] = 10.0
			gpsLabel.text = String(format: "%.0f", 20.0)
			howRecentLabel.text = String(format: "%.0f", 10.0)
		}
	}
}
