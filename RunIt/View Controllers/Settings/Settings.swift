/**
*
*  Settings.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit











class Settings: UITableViewController {
	
	let userDefaults = UserDefaults.standard
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
}





















/*

	MARK: SETTINGS - TABLEVIEW

	-didSelectRowAt

*/

extension Settings {
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// ÖFFNE WEBSEITE
		if indexPath.section == 2 && indexPath.row == 0 {
			if let url = URL(string: "https://github.com/emilianscheel/") {
				UIApplication.shared.open(url)
			}
		}
	}
}






























/*

	MARK: SETTINGS - NAVIGATION

	-segueIdentifier

*/

extension Settings: SegueHandlerType {
	enum SegueIdentifier: String {
		case personal
	}
}
