/**
*
*  Run.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import MapKit
import UIKit












class RunExtension {
	
	static func loadRunsDistance(for distance: Double) -> [Run] {
		let runs = CoreDataStack.loadRuns()
		var qualifiedRuns: [Run] = []
		
		for run in runs {
			if run.distance > distance {
				qualifiedRuns.append(run)
			}
		}
		
		qualifiedRuns.sort(by: { $0.distance < $1.distance })
		
		return qualifiedRuns
	}
	
	static func loadRunsDuration(for duration: Double) -> [Run] {
		let runs = CoreDataStack.loadRuns()
		var qualifiedRuns: [Run] = []
		
		for run in runs {
			if run.duration > duration {
				qualifiedRuns.append(run)
			}
		}
		
		qualifiedRuns.sort(by: { $0.duration < $1.duration })
		
		return qualifiedRuns
	}
	
	static func loadRuns(_ duration: Double, _ distance: Double) -> [Run] {
		let runs = CoreDataStack.loadRuns()
		var qualifiedRuns: [Run] = []
		
		for run in runs {
			if FormatDisplay.pace.from(run.duration, run.distance) > FormatDisplay.pace.from(duration, distance) {
				qualifiedRuns.append(run)
			}
		}
		
		qualifiedRuns.sort(by: { FormatDisplay.pace.from($0.duration, $0.distance) < FormatDisplay.pace.from($1.duration, $1.distance) })
		
		return qualifiedRuns
	}
}




















/*

	MARK: RUNPARAMETER

	-distance
	-duration
	-date

*/

enum RunParameter {
	case distance
	case duration
	case date
}
