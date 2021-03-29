/**
*
*  CompareWidget.swift
*  RunIt
*
*  Created by Emilian Scheel on 09.02.21
*
*/

import WidgetKit
import SwiftUI
import CoreData
import UIKit










struct CompareWidgetProvider: TimelineProvider {
	
	func placeholder(in context: Context) -> CompareWidgetEntry {
		CompareWidgetEntry(date: Date())
	}

	func getSnapshot(in context: Context, completion: @escaping (CompareWidgetEntry) -> Void) {
		let entry = CompareWidgetEntry(date: Date())
		completion(entry)
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<CompareWidgetEntry>) -> Void) {
		var entries: [CompareWidgetEntry] = []

		let entry = CompareWidgetEntry(date: Date())
		entries.append(entry)

		let timeline = Timeline(entries: entries, policy: .atEnd)
		completion(timeline)
	}
}






struct CompareWidgetEntry: TimelineEntry {
	let date: Date
}



struct CompareWidgetEntryView: View {
	
	var entry: CompareWidgetEntry
	@Environment(\.widgetFamily) var family
	
	var body: some View {

		VStack(alignment: .leading) {
						
			HStack(alignment: .top) {
				Text("Vergleich \(FormatDisplay.date.from(date: Date(), "YYYY"))")
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
			
			ChartViewMonth()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color.init(UIColor.secondarySystemBackground))
				.cornerRadius(12)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.cornerRadius(10.0)
		.padding(10)
	}
}












struct CompareWidget: Widget {
	let kind: String = "CompareWidget"
	
	var body: some WidgetConfiguration {
		
		StaticConfiguration(kind: kind, provider: CompareWidgetProvider()) { entry in
			CompareWidgetEntryView(entry: entry)
				.background(Color.init(UIColor.systemBackground))
		}
		.configurationDisplayName("Vergleich")
		.description("Zeigt dir Vergleiche zwischen den Monaten direkt auf dem Home-Screen. Sodass du sie immer im Blick hast.")
		.supportedFamilies([.systemMedium])
	}
}




struct CompareWidgetPreview: PreviewProvider {
	static var previews: some View {
		
		CompareWidgetEntryView(entry: CompareWidgetEntry(date: Date()))
			.previewContext(WidgetPreviewContext(family: .systemLarge))
	}
}


