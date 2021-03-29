/**
 *
 *  UnitExtension.swift
 *  RunIt
 *
 *  Created by Emilian Scheel on 09.02.21
 *
 */




import Foundation

class UnitConverterPace: UnitConverter {
  private let coefficient: Double
  
  init(coefficient: Double) {
    self.coefficient = coefficient
  }
  
  override func baseUnitValue(fromValue value: Double) -> Double {
    return reciprocal(value * coefficient)
  }
  
  override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
    return reciprocal(baseUnitValue * coefficient)
  }
  
  private func reciprocal(_ value: Double) -> Double {
    guard value != 0 else { return 0 }
    return 1.0 / value
  }
}

class Calories {
	
	var age: Int = 0		// given as Number
	var weight: Int = 0		// given in Kilogramm
	var heartRate: Int = 0	// given in beats per minute
	var time: Int = 0		// given in Minuten
	
	static func For(age: Int, weight: Int, heartRate: Int, minutes: Int) -> Double {
		return (Double(age)*0.2017) + ((Double(weight)*2.205)*0.09036) + (Double(heartRate)*0.6309 - 55.0969) * Double(minutes) / 4.184
	}
	
	
	// [(Age x 0.2017) + ((Weight*2,205) x 0.09036) + (Heart Rate x 0.6309) - 55.0969] x Time / 4.184
	
	//	Age in years.
	//	Weight in pounds.
	//	HR in beats per minute.
	//	Time in minutes.
}

extension UnitSpeed {
  class var secondsPerMeter: UnitSpeed {
    return UnitSpeed(symbol: "sec/m", converter: UnitConverterPace(coefficient: 1))
  }
  
  class var minutesPerKilometer: UnitSpeed {
    return UnitSpeed(symbol: "min/km", converter: UnitConverterPace(coefficient: 60.0 / 1000.0))
  }
  
  class var minutesPerMile: UnitSpeed {
    return UnitSpeed(symbol: "min/mi", converter: UnitConverterPace(coefficient: 60.0 / 1609.34))
  }
}
