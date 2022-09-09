//
//  EventManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.12.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import EventKit

class EventManager : ObservableObject{
    
    @Published var events : [EKEvent] = [EKEvent]()
    let eventStore = EKEventStore()
    
    init() async {
        await requestEvents()
    }
    
    init(isDemo: Bool = false){
        if isDemo{
            events = exampleEvents
        }
    }
    
    var exampleEvents : [EKEvent] {
        
        var events = [EKEvent]()
        
        for i in 0...4 {
            
            let event = EKEvent(eventStore: self.eventStore)
            event.title = "Demo Event \(i+1)"
            event.startDate = Date()
            event.endDate = Date()
            
            events.append(event)
            
        }
        
        return events
        
    }
    
    func requestEvents() async{
        
        do {
            _ = try await eventStore.requestAccess(to: .event)
            await self.findCalendar()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func findCalendar() async{
        let calendars1 = self.eventStore.calendars(for: .event)
        
        if let petCalendar = calendars1.first(where: {$0.title == "Pet Reminder"}){
            await self.loadEvents(from: petCalendar)
        } else {
            await self.createCalendar()
            
        }
    }
    
    func createCalendar() async {
        
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "Pet Reminder"
        
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents{
            calendar.source = defaultCalendar.source
        }
        
        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func loadEvents(from calendar : EKCalendar) async{
        let status = EKEventStore.authorizationStatus(for: .event)
        
        if status == .authorized {
            
            let startDate = Date()
            //            86400 = tomowwow.
            let endDate = Date(timeIntervalSinceNow: 86400*3)
            DispatchQueue.main.async {
                let predicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                self.events = self.eventStore.events(matching: predicate)
            }
        } else {
            await requestEvents()
        }
    }
    
    
    func reloadEvents() async{
        let calendars1 = self.eventStore.calendars(for: .event)
        
        if let petCalendar = calendars1.first(where: {$0.title == "Pet Reminder"}){
            await self.loadEvents(from: petCalendar)
        }
    }
    
    func convertDateToString(startDate: Date?, endDate: Date?) async->String{
        
        if let startDate = startDate {
            let start = startDate.formatted(date: .numeric, time: .standard)
            if let endDate = endDate {
                let end = endDate.formatted(date: .numeric, time: .standard)
                return "\(start) - \(end)"
            }
            return start
        }
        return ""
    }
    
    func removeEvent(event: EKEvent) async{
        do {
            try self.eventStore.remove(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func saveEvent(name : String, start : Date, end: Date = Date(), isAllDay: Bool = false) async{
        
        let calendars1 = eventStore.calendars(for: .event)
        
        if let petCalendar = calendars1.first(where: {$0.title == "Pet Reminder"}) {
            let newEvent = EKEvent(eventStore: eventStore)
            newEvent.title = name
            newEvent.isAllDay = isAllDay
            
            if isAllDay {
                newEvent.startDate = start
                newEvent.endDate = start
            } else {
                newEvent.startDate = start
                newEvent.endDate = end
            }
            
            newEvent.calendar = petCalendar
            
            
            newEvent.addAlarm(EKAlarm(relativeOffset: -60*10))
            newEvent.notes = NSLocalizedString("add_event_note", comment: "")
            
            do {
                try eventStore.save(newEvent, span: .thisEvent)
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
