//
//  CalendarManager.swift
//  WeatherNow
//
//  Created by David Muñoz on 28/11/2024.
//

import EventKit
import Combine

public protocol CalendarManager {
    func addCalendarEvents() -> AnyPublisher<Bool, Error>
}


public final class DefaultCalendarManager: CalendarManager {
    
    private let eventStore = EKEventStore()
    private lazy var status = EKEventStore.authorizationStatus(for: .event)

    private let calendarEventsSubject: PassthroughSubject<Bool, Error> = .init()
    public func addCalendarEvents() -> AnyPublisher<Bool, Error>  {
        switch status{
        case .notDetermined:
            requestAccess()
        case .fullAccess, .writeOnly:
            delayedSaveEvents()
        default:
            calendarEventsSubject.send(false)
        }
        return calendarEventsSubject.eraseToAnyPublisher()
    }
    
    private func requestAccess() {
        eventStore.requestFullAccessToEvents { granted, _ in
            if granted {
                self.delayedSaveEvents()
            } else {
                self.calendarEventsSubject.send(false)
            }
        }
    }
    
    private func delayedSaveEvents() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.saveEvents()
        }
    }
    private func saveEvents() {
        guard let startDate = getNextDayMidnight() else { return }
        let event = EKEvent(eventStore: eventStore)
        event.title = "calendarEvent.title".localized
        event.notes = "calendarEvent.message".localized
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(60 * 20)
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
            calendarEventsSubject.send(true)
        } catch {
            calendarEventsSubject.send(false)
        }
    }
}

func getNextDayMidnight() -> Date? {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    let today = Date()
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)
    
    var components = calendar.dateComponents([.year, .month, .day], from: tomorrow ?? today)
    components.hour = 0
    components.minute = 0
    components.second = 0
    
    return calendar.date(from: components)
}
