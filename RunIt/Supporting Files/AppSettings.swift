
/**
*
*  AppSettings.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation











public enum AppSettings {
	
	// New enum with the Keys, add all settings key here
	public enum key: String {
		case howRecent = "howRecent"
		case gpsAccuaracy = "gpsAccuaracy"
		case locationRadius = "locationRadius"
		case shareNewRun = "shareNewRun"
		
		
		case alert_showNoLocationsSaved = "alert_showNoLocationsSaved"
		case alert_showNoCameraAvailable = "alert_showNoCameraAvailable"
		
		
		case user_bodyHeight = "user_BodyHeight"
		case user_bodyWeight = "user_BodyWeight"
		case user_stepWeight = "user_StepWeight"
	}
	
	public static subscript(_ key: key) -> Any? { // the parameter key have a enum type `key`
		get { // need use `rawValue` to acess the string
			return UserDefaults.standard.value(forKey: key.rawValue)
		}
		set { // need use `rawValue` to acess the string
			UserDefaults.standard.setValue(newValue, forKey: key.rawValue)
		}
	}
}

extension AppSettings {
	
	public static func boolValue(_ key: key) -> Bool {
		if let value = AppSettings[key] as? Bool {
			return value
		}
		return false
	}
	
	public static func stringValue(_ key: key) -> String? {
		if let value = AppSettings[key] as? String {
			return value
		}
		return nil
	}
	
	public static func intValue(_ key: key) -> Int? {
		if let value = AppSettings[key] as? Int {
			return value
		}
		return nil
	}
	
	public static func doubleValue(_ key: key) -> Double? {
		if let value = AppSettings[key] as? Double {
			return value
		}
		return nil
	}
}

