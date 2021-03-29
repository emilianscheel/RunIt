/**
*
*  AppDelegate.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import UIKit








@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	
	
	// MARK: application -> didFinishLaunchingWithOptions
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		let locationManager = LocationManager.shared
		locationManager.requestWhenInUseAuthorization()
		
		let storredTheme = UserDefaults.standard.integer(forKey: "AppTheme")
		
		if #available(iOS 13.0, *) {
		switch storredTheme {
			
				// THEME SYSTEM
				case 0:
					window?.overrideUserInterfaceStyle = .unspecified
					
				// THEME LIGHT
				case 1:
					window?.overrideUserInterfaceStyle = .light
					
				// THEME DARK
				case 2:
					window?.overrideUserInterfaceStyle = .dark
					
				default:
					window?.overrideUserInterfaceStyle = .unspecified
			}
		}
		
		return true
	}
	
	
	
	// MARK: applicationDidEnterBackground
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		CoreDataStack.saveContext()
	}
	
	
	
	// MARK: applicationWillTerminate
	
	func applicationWillTerminate(_ application: UIApplication) {
		CoreDataStack.saveContext()
	}
	
	
	
	// MARK: applicationWillResignActive
	
	func applicationWillResignActive(_ application: UIApplication) {
		
		var shortcuts: [UIApplicationShortcutItem] = []
		
		// add NewRun-Shortcut-Action
		shortcuts.append(UIApplicationShortcutItem(type: "run.it.NewRunActionTapped", localizedTitle: "Neuer Lauf", localizedSubtitle: "", icon: UIApplicationShortcutIcon(systemImageName: "plus")))
		
		// add PastRun-Shortcut-Action
		shortcuts.append(UIApplicationShortcutItem(type: "run.it.PastRunsActionTapped", localizedTitle: "Letzte Läufe", localizedSubtitle: "", icon: UIApplicationShortcutIcon(systemImageName: "clock")))
		
		// add Goals-Shortcut-Action
		shortcuts.append(UIApplicationShortcutItem(type: "run.it.GoalsActionTapped", localizedTitle: "Ziele", localizedSubtitle: "Lege dir Ziele fest!", icon: UIApplicationShortcutIcon(systemImageName: "flag")))
		
		application.shortcutItems = shortcuts
	}
	
	
	
	// MARK: application -> performActionFor
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		print(shortcutItem.type)
		
		guard let tabBarController = window?.rootViewController as? TabBarController else {
			return
		}
		
		guard let applicationShortcuts = ApplicationShortcuts(rawValue: shortcutItem.type) else {
			return
		}
		
		// SHORTCUTITEM TYPE
		switch applicationShortcuts {
			
			// PastRunAction is triggered
			case .pastRuns:
				tabBarController.selectedIndex = 0
				break
				
			// NewRunAction is triggered
			case .newRun:
				tabBarController.selectedIndex = 1
				break
				
			// GoalsAction is triggered
			case .goals:
				tabBarController.selectedIndex = 2
				break
		}
	}
	
	
	
	// MARK: application -> continueUserActivity
	
	func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
		
		// get userActivityShortcuts as UserActivityShorcut
		guard let userActivityShortcuts = UserActivityShortcuts(rawValue: userActivityType) else {
			return false
		}
		
		// switch userActivityShorcuts
		switch userActivityShortcuts {
			
			// run.it.newRunShortcut is triggered -> do any addional to open „CountDown-ViewController"
			case .newRun:
				break
				
			// run.it.lastRunsShortcut is triggered -> do any addional to open „LastRuns-Tab"
			case .lastRuns:
				break
				
			// run.it.goalsShortcut is triggered -> do any addional to open „Goals-Tab"
			case .goals:
				break
		}
		
		return false
	}
	
	// MARK: window -> Theme
	
	func changeTheme(to: AppTheme) {
		if #available(iOS 13.0, *) {
			switch to {
				case .dark:
					window?.overrideUserInterfaceStyle = .dark
					UserDefaults.standard.set(2, forKey: "AppTheme")
					break
				case .light:
					window?.overrideUserInterfaceStyle = .light
					UserDefaults.standard.set(1, forKey: "AppTheme")
					break
				case .system:
					window?.overrideUserInterfaceStyle = .unspecified
					UserDefaults.standard.set(0, forKey: "AppTheme")
			}
		}
	}
	
	
	enum AppTheme: Int {
		case system = 0
		case light = 1
		case dark = 2
	}
	
	
	enum UserActivityShortcuts: String {
		case newRun = "run.it.new.run"
		case lastRuns = "run.it.last.runs"
		case goals = "run.it.goals"
	}
	
	enum ApplicationShortcuts: String {
		case newRun = "run.it.NewRunActionTapped"
		case pastRuns = "run.it.PastRunsActionTapped"
		case goals = "run.it.GoalsActionTapped"
	}
	
	@available(iOS 13.0, *)
	static var getTheme: UIUserInterfaceStyle {
		return UIScreen.main.traitCollection.userInterfaceStyle
	}
}
