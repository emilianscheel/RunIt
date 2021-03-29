
/**
*
*  LaunchScreen.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/
import UIKit










class LaunchScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		// Lade die AppDelegate
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
		   return
		}
		
		let storredTheme = UserDefaults.standard.integer(forKey: "AppTheme")
		
		appDelegate.changeTheme(to: AppDelegate.AppTheme(rawValue: storredTheme)!)
    }
}
