
/**
*
*  CoreDataStack.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import Foundation
import CoreData
import WidgetKit
















class CoreDataStack {
	static let shared = CoreDataStack()

	private init() {}

	private let persistentContainer: NSPersistentContainer = {
		let storeURL = FileManager.appGroupContainerURL.appendingPathComponent("DataModel.sqlite")
		let container = NSPersistentContainer(name: "DataModel")
		container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
		container.loadPersistentStores(completionHandler: { storeDescription, error in
			if let error = error as NSError? {
				print(error.localizedDescription)
			}
		})
		return container
	}()
}






















/*

	MARK: CORE DATA STACK - CONTEXT

	-managedObjectContext
	-saveContext

*/

extension CoreDataStack {
	
	var managedObjectContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}

	func saveContext() {
		managedObjectContext.performAndWait {
			if managedObjectContext.hasChanges {
				do {
					try managedObjectContext.save()
				} catch {
					print(error.localizedDescription)
				}
			}
		}
		WidgetCenter.shared.reloadAllTimelines()
	}
}





















/*

	MARK: CORE DATA STACK - WORKING CONTEXT

	-workingContext
	-saveWorkingContext

*/

extension CoreDataStack {
	
	var workingContext: NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.parent = managedObjectContext
		return context
	}

	func saveWorkingContext(context: NSManagedObjectContext) {
		do {
			try context.save()
			saveContext()
			WidgetCenter.shared.reloadAllTimelines()
		} catch {
			print(error.localizedDescription)
		}
	}
}























/*

	MARK: CORE DATA STACK - RUNS

	-loadRuns
	-updateRun

*/

extension CoreDataStack {
	
	static func loadRuns() -> [Run] {
		
		let request = NSFetchRequest<Run>(entityName: "Run")
		
		do {
			let result = try CoreDataStack.shared.managedObjectContext.fetch(request)
			return result
			
		} catch {
			print(error)
		}
		
		return []
	}
	
	static func loadRunsSorted(by parameter: RunParameter) -> [Run] {
		
		let request = NSFetchRequest<Run>(entityName: "Run")
		
		do {
			var result = try CoreDataStack.shared.managedObjectContext.fetch(request)
			
			switch parameter {
				case .distance:
					result.sort(by: { $0.distance > $1.distance })
				case .duration:
					result.sort(by: { $0.duration > $1.duration })
				case .date:
					result.sort(by: { $0.date!.compare($1.date!) == .orderedDescending })
			}
			
			return result
			
		} catch {
			print(error)
		}
		
		return []
	}
	
	
	static func dummyRuns() -> [Run] {
		let run1 = Run(context: CoreDataStack.shared.workingContext)
		run1.distance = 1235
		run1.duration = 3000
		run1.date = Date()
		
		let run2 = Run(context: CoreDataStack.shared.workingContext)
		run2.distance = 847
		run2.duration = 2356
		run2.date = Date()
		
		return [run1, run2]
	}
	
	static func lastRuns(count: Int) -> [Run] {
		let runs = CoreDataStack.loadRuns()
		var returnRuns: [Run] = []
		for (index, run) in runs.enumerated() {
			if index < count {
				returnRuns.append(run)
			}
		}
		return returnRuns
	}
	
	
	static func updateRun(at index: Int, newRun: Run) {
		let request = NSFetchRequest<Run>(entityName: "Run")
		
		do {
			var result = try CoreDataStack.shared.managedObjectContext.fetch(request)
			result[index] = newRun
			shared.saveContext()
			
		} catch {
			print(error)
		}
	}
}





















/*

	MARK: CORE DATA STACK - TARGETS

	-loadRuns
	-updateRun

*/

extension CoreDataStack {
	
	static func loadTargets() -> [Target] {
		
		let request = NSFetchRequest<Target>(entityName: "Target")
		
		do {
			let result = try CoreDataStack.shared.managedObjectContext.fetch(request)
			return result
			
		} catch {
			print(error)
		}
		
		return []
	}
	
	
	static func updateTarget(at index: Int, newRun: Target) {
		let request = NSFetchRequest<Target>(entityName: "Target")
		
		do {
			var result = try CoreDataStack.shared.managedObjectContext.fetch(request)
			result[index] = newRun
			shared.saveContext()
			
		} catch {
			print(error)
		}
	}
	
	static func loadTargets(for distance: Double) -> [Target] {
		let allTargets = loadTargets()
		var targets: [Target] = []
		
		for target in allTargets {
			if distance > target.distance {
				targets.append(target)
			}
		}
		
		return targets
	}
	
	static func nextTarget(for distance: Double) -> Target {
		var targets = loadTargets(for: distance)
		targets.sort(by: { $0.distance < $1.distance })
		return targets[0]
	}
}






























/*

	MARK: FILE MANAGER - APP GROUPS

	-appGroupContainerURL

*/

extension FileManager {
	static let appGroupContainerURL = FileManager.default
		.containerURL(forSecurityApplicationGroupIdentifier: "group.pocket.runit")!
}
