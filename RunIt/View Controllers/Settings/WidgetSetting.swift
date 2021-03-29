/**
*
*  WidgetSettings.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import UIKit
import WidgetKit












class WidgetSettings: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func updateWidgets(_ sender: UIButton) {
		WidgetCenter.shared.reloadAllTimelines()
	}
}
