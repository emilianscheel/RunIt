/**
*
*  MapExtension.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/





import Foundation
import MapKit

class MapExtension {
	
	
	
	
	// MARK: annotations
	
	static func annotations(_ currentRun: Run) -> [MKPointAnnotation] {
		
		return []
	}
	
	
	
	
	
	
	
	
	// MARK: polyLine
	
	static func polyLine(isBlue: Bool, _ currentRun: Run) -> [MulticolorPolyline] {
		
		var locationList: [CLLocation] = []
		
		// 1
		let locations = currentRun.locations?.array as! [Location]
		var coordinates: [(CLLocation, CLLocation)] = []
		var speeds: [Double] = []
		var minSpeed = Double.greatestFiniteMagnitude
		var maxSpeed = 0.0
		
		// 2
		for (first, second) in zip(locations, locations.dropFirst()) {
			let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
			let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
			coordinates.append((start, end))
			locationList.append(start)
			
			//3
			let distance = end.distance(from: start)
			let time = second.timestamp!.timeIntervalSince(first.timestamp! as Date)
			let speed = time > 0 ? distance / time : 0
			speeds.append(speed)
			minSpeed = min(minSpeed, speed)
			maxSpeed = max(maxSpeed, speed)
		}
		
		//4
		let midSpeed = speeds.reduce(0, +) / Double(speeds.count)
		
		//5
		var segments: [MulticolorPolyline] = []
		for ((start, end), speed) in zip(coordinates, speeds) {
			let coords = [start.coordinate, end.coordinate]
			let segment = MulticolorPolyline(coordinates: coords, count: 2)
			if isBlue {
				segment.color = .systemBlue
			} else {
				segment.color = self.segmentColor(speed: speed,
												  midSpeed: midSpeed,
												  slowestSpeed: minSpeed,
												  fastestSpeed: maxSpeed)
			}
			segments.append(segment)
		}
		
		return segments
	}
	
	
	
	
	
	
	
	
	
	
	// MARK: segmentColor
	
	static func segmentColor(speed: Double, midSpeed: Double, slowestSpeed: Double, fastestSpeed: Double) -> UIColor {
		
		enum BaseColors {
			static let r_red: CGFloat = 1
			static let r_green: CGFloat = 20 / 255
			static let r_blue: CGFloat = 44 / 255
			
			static let y_red: CGFloat = 1
			static let y_green: CGFloat = 215 / 255
			static let y_blue: CGFloat = 0
			
			static let g_red: CGFloat = 0
			static let g_green: CGFloat = 146 / 255
			static let g_blue: CGFloat = 78 / 255
		}
		
		let red, green, blue: CGFloat
		
		if speed < midSpeed {
			let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
			red = BaseColors.r_red + ratio * (BaseColors.y_red - BaseColors.r_red)
			green = BaseColors.r_green + ratio * (BaseColors.y_green - BaseColors.r_green)
			blue = BaseColors.r_blue + ratio * (BaseColors.y_blue - BaseColors.r_blue)
		} else {
			let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
			red = BaseColors.y_red + ratio * (BaseColors.g_red - BaseColors.y_red)
			green = BaseColors.y_green + ratio * (BaseColors.g_green - BaseColors.y_green)
			blue = BaseColors.y_blue + ratio * (BaseColors.g_blue - BaseColors.y_blue)
		}
		
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	// MARK: mapRegion
	
	static func mapRegion(_ currentRun: Run) -> MKCoordinateRegion? {
		guard
			let locations = currentRun.locations,
			locations.count > 0
		else {
			return nil
		}
		
		let latitudes = locations.map { location -> Double in
			let location = location as! Location
			return location.latitude
		}
		
		let longitudes = locations.map { location -> Double in
			let location = location as! Location
			return location.longitude
		}
		
		let maxLat = latitudes.max()!
		let minLat = latitudes.min()!
		let maxLong = longitudes.max()!
		let minLong = longitudes.min()!
		
		let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
											longitude: (minLong + maxLong) / 2)
		let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 2,
									longitudeDelta: (maxLong - minLong) * 2)
		return MKCoordinateRegion(center: center, span: span)
	}
	
	static func mapRegion(for locations: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
		
		let latitudes = locations.map { location -> Double in
			let location = location
			return location.latitude
		}
		
		let longitudes = locations.map { location -> Double in
			let location = location
			return location.longitude
		}
		
		let maxLat = latitudes.max()!
		let minLat = latitudes.min()!
		let maxLong = longitudes.max()!
		let minLong = longitudes.min()!
		
		let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
											longitude: (minLong + maxLong) / 2)
		let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 2,
									longitudeDelta: (maxLong - minLong) * 2)
		return MKCoordinateRegion(center: center, span: span)
	}
}
