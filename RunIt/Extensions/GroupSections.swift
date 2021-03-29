/**
*
*  SectionManager.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/











import Foundation

class GroupSections {
	
	static func group(_ runs: [Run], by component: Calendar.Component) -> [Object] {

		var groupedRuns: [Object] = [Object]()
		
		// Für jeden Lauf in ‘runs‘ gehe den Algorythmus durch
		// Nehme dabei jeweils auch den ‘index‘
		for (index, run) in runs.enumerated() {
			
			
			
			// Lade den Kalender und setze deren Zeitzone auf diese
			var calendar = NSCalendar.current
			calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
			
			// Für jeden Lauf in ‘groupedRuns‘:
			// 1. Prüfe, ob der Monat von dem Lauf aus ‘runs‘ der gleiche ist, wie der aus dem aktuellen ‘groupedRuns‘-Lauf
			// 2. Prüfe, ob das Jahr von dem Lauf aus ‘runs‘ der gleiche ist, wie der aus dem aktuellen ‘groupedRuns‘-Lauf
			// 3. Wenn beide Bedingugen erfüllt sind, dann füge den Lauf aus ‘runs‘ zu der Gruppe der ‘groupedRuns‘ hinzu
			// 4. Wenn das hier der letzte ‘groupedRuns‘-Lauf ist und der Lauf aus ‘runs‘ immernoch nicht zugeordnet wurde, dann erstelle ein neue Gruppe
			for (index1, groupedRun) in groupedRuns.enumerated() {
							
				let monthSame = calendar.isDate(groupedRun.date, equalTo: run.date!, toGranularity: component)
				
				
				if monthSame {
					groupedRuns[index1].rows.append(ObjectRowRun(run: run, index: index))
					
				} else if !monthSame && index1 == groupedRuns.count-1 {
					groupedRuns.append(Object(date: run.date!, rows: [ObjectRowRun(run: run, index: index)]))
				}
			}
			
			if groupedRuns.count == 0 {
				groupedRuns.append(Object(date: run.date!, rows: [ObjectRowRun(run: run, index: index)]))
			}
		}
		
		return groupedRuns
	}
	
	static func groupInMonths(_ runs: [Run]) -> [Object] {
		

		// the desired format
		var sortedDatesByMonth: [Object] = []
		
		let calendar = Calendar.current
		
		/// $0.date!.month == month &&

		// a filter to filter months by a given integer, you could also pull rawDates out of the equation here, to make it pure functional
		let filterRunsByMonth = { month in runs.filter { calendar.isDate($0.date!, equalTo: date(from: month), toGranularity: .month) } }
		// loop through the months in a calendar and for every month filter the dates and append them to the array
		(1...12).forEach { sortedDatesByMonth.append(Object(rows: getObjectRowRuns(for: filterRunsByMonth($0)), month: $0)) }
		
		print("lkasjdf: \(sortedDatesByMonth.count)")
		
		return sortedDatesByMonth
	}
	
	static func date(from month: Int) -> Date {
		
		let calendar = Calendar.current
		let year = Calendar.current.component(.year, from: Date())
		
		return calendar.date(from: DateComponents(year: year, month: month))!
	}
	
	static func groupInMonthsSorted(_ runs: [Run], by sortingCriteria: GroupSorting) -> [Object] {
		
		var months = GroupSections.groupInMonths(runs)
		
		switch sortingCriteria {
			case .count:
				months.sort(by: { lhs, rhs in lhs.rows.count > rhs.rows.count })
			case .month:
				months.sort { lhs, rhs in lhs.month < rhs.month }
		}
		
		return months
	}
	
	enum GroupSorting {
		case count
		case month
	}
	
	static func getObjectRowRuns(for runs: [Run]) -> [ObjectRowRun] {
		
		var endRuns: [ObjectRowRun] = []
		for run in runs {
			let object = ObjectRowRun(run: run)
			endRuns.append(object)
		}
		return endRuns
	}
}



extension Date {

	var month: Int {
		return Calendar.current.component(.month, from: self)
	}
	
	static func monthInitial(from int: Int) -> String {
		switch int {
			case 1:
				return "J"
			case 2:
				return "F"
			case 3:
				return "M"
			case 4:
				return "A"
			case 5:
				return "M"
			case 6:
				return "J"
			case 7:
				return "J"
			case 8:
				return "A"
			case 9:
				return "S"
			case 10:
				return "O"
			case 11:
				return "N"
			case 12:
				return "D"
			default:
				return ""
		}
	}
}







extension GroupSections {
	
	class Object: Identifiable {
		var rows: [ObjectRow]!
		var date: Date
		var month: Int!

		init(date: Date = Date(), rows: [ObjectRow], month: Int = 0) {
			self.rows = rows
			self.date = date
			self.month = month
		}
	}

	class ObjectRow: Identifiable {  }
}

class ObjectRowRun: GroupSections.ObjectRow {
	var run: Run
	var index: Int
	
	init(run: Run, index: Int = 0) {
		self.run = run
		self.index = index
	}
}
