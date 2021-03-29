/**
*
*  PastRunWidget.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import CoreData
import UIKit









class SuccessStack {
	
	
	static let runs: [Run] = CoreDataStack.loadRuns()
	
	static var totalDistance: Double {
		var totalDistance: Double = 0 		// Einheit: Meter
		for run in runs {
			totalDistance = totalDistance + run.distance
		}
		if totalDistance.isNaN { totalDistance = 0 }
		return totalDistance
	}
	
	
	static var totalDuration: Double {
		var totalDuration: Double = 0 		// Einheit: Sekunden
		for run in runs {
			totalDuration = totalDuration + Double(run.duration)
		}
		if totalDuration.isNaN { totalDuration = 0 }
		return totalDuration
	}
	
	
	static var averagePace: Double {
		var averagePace: Double = 0 		// Einheit: Minuten/Kilometer
		for run in runs {
			let kilometers = run.distance/1000
			let minutes = run.duration/60
			let pace = Double(minutes) / kilometers
			averagePace += pace
		}
		// Formatiere die Durchschnitts-Pace pro Lauf.
		averagePace = averagePace / Double(runs.count)
		return averagePace
	}
	
	
	static var averageDistance: Double {
		var averageDistance: Double = 0 		// Einheit: Meter
		for run in runs {
			averageDistance += run.distance
		}
		// Formatiere die Durchschnitts-Pace pro Lauf.
		averageDistance = averageDistance / Double(runs.count)
		if averageDistance.isNaN { averageDistance = 0 }
		return averageDistance
	}
	
	
	static var averageDuration: Double {
		var averageDuration: Double = 0 		// Einheit: Sekunden
		for run in runs {
			averageDuration += Double(run.duration)
		}
		// Formatiere die Durchschnitts-Pace pro Lauf.
		averageDuration = averageDuration / Double(runs.count)
		if averageDuration.isNaN { averageDuration = 0 }
		return averageDuration
	}
	
	
	static var averageSteps: Double {
		
		let stepWeights = AppSettings.intValue(.user_stepWeight) ?? 0
		let stepWeight = Double(stepWeights)
		var averageSteps: Double = 0 		// Einheit: Zentimeter
		for run in runs {
			let distance = run.distance*100
			averageSteps += distance/stepWeight
		}
		// Formatiere die Durchschnitts-Pace pro Lauf.
		averageSteps = averageSteps / Double(runs.count)
		if averageSteps.isNaN { averageSteps = 0 }
		return averageSteps
	}
	
	static var totalSteps: Double {
		
		let stepWeights = AppSettings.intValue(.user_stepWeight) ?? 0
		let stepWeight = Double(stepWeights)
		var totalSteps: Double = 0 			// Einheit: Zentimeter
		for run in runs {
			let distance = run.distance*100
			totalSteps += distance/stepWeight
		}
		
		return totalSteps
	}
}
