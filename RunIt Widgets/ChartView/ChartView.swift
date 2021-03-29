
/**
*
*  ChartView.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import SwiftUI
import WidgetKit
import CoreData
import UIKit










/*

	MARK: GRIDSECTION VIEW

	-title
	-value
	-family

	-chartviewDistance
	-chartviewDuration

	-body

*/

struct GridSectionView: View {
	var title: String
	var value: String
	var family: WidgetFamily
	var chartviewDistance: ChartViewDistance? = nil
	var chartviewDuration: ChartViewDuration? = nil
	
	var body: some View {
		
		HStack(alignment: .top) {
			
			RoundedRectangle(cornerRadius: 1)
				.frame(width: 3, height: .infinity, alignment: .center)
				.foregroundColor(.blue)
			
			VStack {
				
				Text(title)
					.foregroundColor(Color(UIColor.label))
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.caption2)
				
				Text(value)
					.foregroundColor(Color(UIColor.label))
					.frame(maxWidth: .infinity, alignment: .leading)
				
				
				if family == .systemLarge && chartviewDistance != nil {
					chartviewDistance
				} else if family == .systemLarge && chartviewDuration != nil {
					chartviewDuration
				}
			}
			.padding(10)
		}
		.background(Color.init(UIColor.secondarySystemBackground))
		.cornerRadius(10.0)
	}
}





























/*

	MARK: CHARTVIEW DISTANCE

	-body

*/

struct ChartViewDistance: View {
	
	var body: some View {
		
		// Zeige ein Diagram für die letzten Läufe
		let runs = CoreDataStack.loadRunsSorted(by: .distance)
		
		let highest = runs[0].distance
		let relation = Double(80/highest)
		let compileRuns = CoreDataStack.loadRunsSorted(by: .date)
		
		
		HStack(alignment: .bottom) {
			ForEach(0..<compileRuns.count) { index in
				if index < 6 {
					ChartViewRowDistance(run: compileRuns[index], relation: relation)
				}
			}
		}
	}
}

struct ChartViewRowDistance: View {
	let run: Run
	let relation: Double
	
	var body: some View {
		
		RoundedRectangle(cornerRadius: 5)
			.frame(maxWidth: .infinity, maxHeight: CGFloat(relation*run.distance), alignment: .leading)
			.foregroundColor(.blue)
	}
}



























/*

	MARK: CHARTVIEW DURATION

	-body

*/

struct ChartViewDuration: View {
	
	var body: some View {
		
		// Zeige ein Diagram für die letzten Läufe
		let runs = CoreDataStack.loadRunsSorted(by: .duration)
		
		let highest = runs[0].distance
		let relation = Double(80/highest)
		let compileRuns = CoreDataStack.loadRunsSorted(by: .date)
		
		
		HStack(alignment: .bottom) {
			ForEach(0..<compileRuns.count) { index in
				if index < 6 {
					ChartViewRowDuration(run: compileRuns[index], relation: relation)
				}
			}
		}
	}
}


struct ChartViewRowDuration: View {
	let run: Run
	let relation: Double
	
	var body: some View {
		
		VStack {
			
			RoundedRectangle(cornerRadius: 5)
				.frame(maxWidth: .infinity, maxHeight: CGFloat(relation*run.duration), alignment: .leading)
				.foregroundColor(.blue)
		}
	}
}































/*

	MARK: CHARTVIEW MONTH

	-body

*/

struct ChartViewMonth: View {
	
	var body: some View {
		
		let runs = CoreDataStack.loadRuns()
		// Gruppiere sie nach Monaten und sortiere sie nach Datum
		let filteredRuns = GroupSections.groupInMonthsSorted(runs, by: .count)
		
		// Berechne den Monat mit den meisten Läufen und die Relation dazu
		let highest = filteredRuns.first?.rows.count
		let relation = Double(80/highest!)
		let compileRuns = GroupSections.groupInMonthsSorted(runs, by: .month)
		
		HStack(alignment: .bottom) {
			ForEach(0..<compileRuns.count) { index in
				if index < 12 {
					if compileRuns[index].rows.count == 0 {
						ChartViewRowMonth(count: 0.2, relation: relation, month: index+1)
					} else {
						ChartViewRowMonth(count: Double(compileRuns[index].rows.count), relation: relation, month: index+1)
					}
				}
			}
		}
		.padding(10)
	}
}

struct ChartViewRowMonth: View {
	let count: Double
	let relation: Double
	let month: Int
	
	var body: some View {
		
		VStack {
			
			Text(String(Int(count)))
				.font(.caption)
			
			RoundedRectangle(cornerRadius: 5)
				.frame(maxWidth: .infinity, maxHeight: CGFloat(relation*count), alignment: .leading)
				.foregroundColor(.blue)
			
			if Date().month == month {
				
				Text(Date.monthInitial(from: month))
					.font(.caption)
				
			} else {
				
				Text(Date.monthInitial(from: month))
					.font(.caption)
					.foregroundColor(.gray)
			}
		}
	}
}
