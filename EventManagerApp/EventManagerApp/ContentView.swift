//
//  ContentView.swift
//  EventManagerApp
//
//  Created by Shiaggar on 30/12/24.
//

import SwiftUI

struct Event: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var description: String
}

class EventManager: ObservableObject {
    @Published var events: [Event] = []
    
    func addEvent(title: String, date: Date, description: String) {
        let newEvent = Event(title: title, date: date, description: description)
        events.append(newEvent)
    }
    
    func removeEvent(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
    }
}

struct ContentView: View {
    @StateObject private var eventManager = EventManager()
    @State private var showAddEventView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(eventManager.events) { event in
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.date, style: .date)
                            .font(.subheadline)
                        Text(event.description)
                            .font(.body)
                            .lineLimit(2)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: eventManager.removeEvent)
            }
            .navigationTitle("Event Manager")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddEventView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                }.sheet(isPresented: $showAddEventView) {
                AddEventView(eventManager: eventManager)
            }
        }
    }
}

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var eventManager: EventManager
                  
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var description: String = ""
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        eventManager.addEvent(title: title, date: date, description: description)
                        dismiss()
                    }.disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
                  
}

#Preview {
    ContentView()
}
