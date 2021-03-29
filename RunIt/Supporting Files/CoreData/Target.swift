/**
*
*  Target.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/






import Foundation
import MapKit
import UIKit

class TargetExtension {
	
	struct RunReachedParameter {
		var kind: RunReachedParameterKind
		var reached: Bool
		var value: String
	}
	
	enum RunReachedParameterKind {
		case distance
		case duration
		case pace
		case location
	}
	
	static func parameters(for target: Target, _ run: Run) -> [RunReachedParameter] {
		var givenParameters: [RunReachedParameter] = []

		// Überprüfe, ob die Distanz gegeben ist, und wenn ja, dann ob diese erreicht wurde
		if target.distance != 0 {
			if run.distance > target.distance {
				givenParameters.append(RunReachedParameter(kind: .distance, reached: true, value: FormatDisplay.distance.from(run.distance)))
			} else {
				givenParameters.append(RunReachedParameter(kind: .distance, reached: false, value: FormatDisplay.distance.from(run.distance)))
			}
		}
		
		// Überprüfe, ob die Zeit gegeben ist, und wenn ja, dann ob diese erreicht wurde
		if target.duration != 0 {
			if run.duration > target.duration {
				givenParameters.append(RunReachedParameter(kind: .duration, reached: true, value: FormatDisplay.duration.from(run.duration)))
			} else {
				givenParameters.append(RunReachedParameter(kind: .duration, reached: false, value: FormatDisplay.duration.from(run.duration)))
			}
		}
		
		// Überprüfe, ob Pace min/km gegeben ist, und wenn ja, dann ob diese erreicht wurde
		if target.pace != 0 {
			if FormatDisplay.pace.from(run.duration, run.distance) < target.pace {
				givenParameters.append(RunReachedParameter(kind: .pace, reached: true, value: FormatDisplay.pace.from(run.duration, run.distance).cropTo(sequences: 1).with(.pace)))
			} else {
				givenParameters.append(RunReachedParameter(kind: .pace, reached: false, value: FormatDisplay.pace.from(run.duration, run.distance).cropTo(sequences: 1).with(.pace)))
			}
		}
		
		// Überprüfe, ob ein Standort gegeben ist, und wenn ja, dann ob dieser erreicht wurde
		if target.location != nil && run.locations != nil{
			for (index, location) in run.locations!.enumerated() {
				let location = location as! Location
				let runCoordinate = CLLocation(latitude: location.latitude, longitude: location.longitude)
				let targetCoordinate = CLLocation(latitude: target.location!.latitude, longitude: target.location!.longitude)
				
				if runCoordinate.distance(from: targetCoordinate) < AppSettings.doubleValue(.locationRadius) ?? 50 {
					givenParameters.append(RunReachedParameter(kind: .location, reached: true, value: ""))
				} else if index == run.locations!.count - 1 {
					givenParameters.append(RunReachedParameter(kind: .location, reached: false, value: ""))
				}
			}
		}
		
		return givenParameters
	}
	
	static func hasReached(_ run: Run, _ target: Target) -> Bool {
		
		let givenParameters = parameters(for: target, run)
		let reached = givenParameters.filter({ !$0.reached })
		
		print(reached)
		
		if reached.count == 0 {
			return false
		} else {
			return true
		}
	}
}
