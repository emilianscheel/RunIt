//
/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import UIKit

class ThemeSettings: UITableViewController {
	
	@IBOutlet weak var systemAppearanceCell: UITableViewCell!
	@IBOutlet weak var lightAppearanceCell: UITableViewCell!
	@IBOutlet weak var darkAppearanceCell: UITableViewCell!
	var storredTheme: Int = 0
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		storredTheme = UserDefaults.standard.integer(forKey: "AppTheme")
		
		if #available(iOS 13.0, *) {
		switch storredTheme {
			
				// THEME SYSTEM
				case 0:
					systemAppearanceCell.accessoryType = .checkmark
					lightAppearanceCell.accessoryType = .none
					darkAppearanceCell.accessoryType = .none
					tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
					
				// THEME LIGHT
				case 1:
					systemAppearanceCell.accessoryType = .none
					lightAppearanceCell.accessoryType = .checkmark
					darkAppearanceCell.accessoryType = .none
					tableView.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none)
					
				// THEME DARK
				case 2:
					systemAppearanceCell.accessoryType = .none
					lightAppearanceCell.accessoryType = .none
					darkAppearanceCell.accessoryType = .checkmark
					tableView.selectRow(at: IndexPath(row: 2, section: 0), animated: false, scrollPosition: .none)
					
				default:
					systemAppearanceCell.accessoryType = .checkmark
					lightAppearanceCell.accessoryType = .none
					darkAppearanceCell.accessoryType = .none
					tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)!
		cell.accessoryType = .none
	}
		
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)!
		cell.selectionStyle = .none
		cell.accessoryType = .checkmark
		
		// get appDelegate
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
		   return
		}
		
		// THEME: SYSTEM
		if indexPath.section == 0 && indexPath.row == 0 {
			appDelegate.changeTheme(to: .system)
		}
		
		// THEME: LIGHT
		if indexPath.section == 0 && indexPath.row == 1 {
			appDelegate.changeTheme(to: .light)
		}
		
		// THEME: DARK
		if indexPath.section == 0 && indexPath.row == 2 {
			appDelegate.changeTheme(to: .dark)
		}
	}
}
