/**
*
*  PastRunWidget.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import WidgetKit
import SwiftUI
import CoreData










struct PastRunWidgetProvider: TimelineProvider {
	
	func placeholder(in context: Context) -> PastRunWigetEntry {
		PastRunWigetEntry(date: Date(), runs: CoreDataStack.loadRuns())
	}

	func getSnapshot(in context: Context, completion: @escaping (PastRunWigetEntry) -> Void) {
		let entry = PastRunWigetEntry(date: Date(), runs: CoreDataStack.loadRuns())
		completion(entry)
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<PastRunWigetEntry>) -> Void) {
		var entries: [PastRunWigetEntry] = []

		let entry = PastRunWigetEntry(date: Date(), runs: CoreDataStack.loadRuns())
		entries.append(entry)

		let timeline = Timeline(entries: entries, policy: .atEnd)
		completion(timeline)
	}
}






struct PastRunWigetEntry: TimelineEntry {
	let date: Date
	let runs: [Run]
}

struct PastRunWidgetEntryView: View {
	
	var entry: PastRunWidgetProvider.Entry
	@Environment(\.widgetFamily) var family
	
	var body: some View {

		VStack(alignment: .leading) {
			
			HStack(alignment: .top) {
				Text("Letzte Läufe")
					.foregroundColor(Color(UIColor.label))
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.leading, 5)
					.font(.caption)
				
				if family == .systemMedium || family == .systemLarge {
					Button("Zur App gehen") {
						WidgetCenter.shared.reloadAllTimelines()
					}
					.font(.caption)
					.foregroundColor(Color(UIColor.systemBlue))
				}

			}
			
			ForEach(0..<entry.runs.count) { index in
								
				if index < rowsFor(family: family) {
					PastRunWidgetRow(family: family, run: entry.runs[index])
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.cornerRadius(10.0)
		.padding(10)
	}
}


struct PastRunWidgetRow: View {
	
	var family: WidgetFamily
	var run: Run
	
	var body: some View {
		
		HStack(alignment: .top) {
			RoundedRectangle(cornerRadius: 1)
				.frame(width: 3, height: .infinity, alignment: .center)
				.foregroundColor(.blue)
			VStack {
				
				Text("Gesamtdistanz")
					.foregroundColor(Color(UIColor.label))
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.caption2)
				
				Text(FormatDisplay.distance.from(run.distance))
					.foregroundColor(Color(UIColor.label))
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			.padding(10)
			
			if family == .systemMedium || family == .systemLarge {
				Text(FormatDisplay.date.from(date: run.date!, "MMMM"))
					.foregroundColor(Color(UIColor.label))
					.padding(10)
					.frame(maxWidth: .infinity, alignment: .trailing)
			}
		}
		.background(Color.init(UIColor.secondarySystemBackground))
		.cornerRadius(12)
	}
}






func rowsFor(family: WidgetFamily) -> Int {
	switch family {
		case .systemSmall: return 2
		case .systemMedium: return 2
		case .systemLarge: return 5
		default: return 2
	}
}


struct PastRunWidget: Widget {
	let kind: String = "PastRunWidget"
	
	var body: some WidgetConfiguration {
		
		StaticConfiguration(kind: kind, provider: PastRunWidgetProvider()) { entry in
			PastRunWidgetEntryView(entry: entry)
				.background(Color.init(UIColor.systemBackground))
		}
		.configurationDisplayName("Letzte Läufe")
		.description("Zeigt deine letzten Aktivitäten auf dem Home-Screen. Sodass du sie immer im Blick hast.")
	}
}








struct PastRunWidgetPreview: PreviewProvider {
	static var previews: some View {
		
		PastRunWidgetEntryView(entry: PastRunWigetEntry(date: Date(), runs: CoreDataStack.dummyRuns()))
			.previewContext(WidgetPreviewContext(family: .systemMedium))
	}
}
