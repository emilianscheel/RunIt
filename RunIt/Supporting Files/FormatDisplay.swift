/**
*
*  FormatDisplay.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import CoreLocation
import UIKit














struct FormatDisplay {
	
	static func gps() -> UIColor {
		let someLocation = CLLocation()
		if (someLocation.horizontalAccuracy < 0) {
			// No Signal
			return .systemGray
		} else if (someLocation.horizontalAccuracy > 163) {
			// Poor Signal
			return .systemRed
		} else if (someLocation.horizontalAccuracy > 48) {
			// Average Signal
			return .systemOrange
		} else {
			// Full Signal
			return .systemGreen
		}
	}
}























/*

	MARK: FORMATDISPLAY - STEPS

	-from

*/

extension FormatDisplay {
	
	class steps {
	
		static func from(_ steps: Double) -> String {
			return String(format: "%.0f", steps)
		}
	}
}

























/*

	MARK: FORMATDISPLAY - KCAL

	-from

*/

extension FormatDisplay {
	
	class kCal {
		
		static func from(_ seconds: Double) -> String {
			let hrs = Double(seconds/600)
			guard let kg = AppSettings.intValue(.user_bodyWeight) else {
				return ""
			}
			let kCal = 6.0 * Double(kg) * hrs
			return String(format: "%.0f", kCal)
		}
	}
}




























/*

	MARK: FORMATDISPLAY - DURATION

	-from

*/

extension FormatDisplay {
	
	class duration {
			
		static func from(_ seconds: Double) -> String {
			let formatter = DateComponentsFormatter()
			formatter.allowedUnits = [.hour, .minute, .second]
			formatter.unitsStyle = .positional
			formatter.zeroFormattingBehavior = .pad
			return formatter.string(from: TimeInterval(Int(seconds)))!
		}
	}
}



























/*

	MARK: FORMATDISPLAY - DISTANCE

	-from

*/

extension FormatDisplay {
	
	class distance {
	
		static func from(_ meters: Double) -> String {
			
			if meters<1000 {
				return String(format: "%.0f", meters) + " m"
			} else {
				return String(format: "%.2f", meters/1000) + " km"
			}
		}
	}
}

























/*

	MARK: FORMATDISPLAY - PACE

	-from
	-from
	-from
	-from

*/

extension FormatDisplay {
	
	class pace {
				
		static func from(_ minutes: Double, _ kilometers: Double) -> Double {
			return minutes / kilometers
		}
	
		static func from(_ seconds: Int64, _ meters: Double) -> Double {
			return (Double(seconds) / (Double(meters/1000))) / 60
		}
		
		static func from(_ seconds: Int, _ meters: Double) -> Double {
			return (Double(seconds) / (Double(meters/1000))) / 60
		}
		
		static func from(_ pace: Int) -> Double {
			return Double(pace)
		}
	}
}
























/*

	MARK: FORMATDISPLAY - DATE

	-from

*/

extension FormatDisplay {
	
	class date {
		
		static func from(date: Date, _ format: String) -> String {
			// DateFormatter
			let formatter = DateFormatter()
			formatter.dateFormat = format
			return formatter.string(from: date)
		}
	}
}























/*

	MARK: FORMATDISPLAY - BANNER

	-duration
	-distance
	-date
	-pace

*/

extension FormatDisplay {
	
	class Banner {
		
		// MARK: format TIME
		
		static func duration(seconds: Double) -> String {
			let formatter = DateComponentsFormatter()
			formatter.allowedUnits = [.hour, .minute, .second]
			formatter.unitsStyle = .positional
			formatter.zeroFormattingBehavior = .pad
			return formatter.string(from: TimeInterval(Int(seconds)))!
		}
		
		// MARK: format DISTANCE
		
		static func distance(metres: Double) -> String {
			return String(format: "%.1f", metres/1000) + " km"
		}
		
		// MARK: format DATE
		
		static func date(date: Date?) -> String {
			guard let timestamp = date as Date? else { return "" }
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			return formatter.string(from: timestamp)
		}
		
		// MARK: format PACE
		
		static func pace(seconds: Double, metres: Double) -> String {
			return FormatDisplay.pace.from(seconds, metres).cropTo(sequences: 1).with(.pace)
		}
	}
}































/*

	MARK: DOUBLE - CROPPING

	-cropTo

*/

extension Double {
	
	func cropTo(sequences: Int) -> String {
		return String(format: "%." + String(sequences) + "f", self)
	}
}









/*

	MARK: STRING - UNITS

	-with
	-Units

*/

extension String {
	
	func with(_ unit: Units) -> String {
		return self + unit.rawValue
	}
	
	enum Units: String {
		case pace = " min/km"
		case minutes = " min"
		case kilometres = " km"
		case metres = " m"
		case seconds = " s"
	}
}
