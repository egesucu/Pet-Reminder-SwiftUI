//
//  EventFilterView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import SharedModels

public struct EventFilterView: View {

    @Binding var eventVM: EventManager
    @Binding var filteredCalendar: EKCalendar?

    public var body: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: 300))]) {
            ZStack {
                if filteredCalendar != nil {
                    Capsule()
                        .fill(Color.black.opacity(0.2))
                } else {
                    Capsule()
                        .fill(Color.black.opacity(0.4))
                }
                Text("All", bundle: .module)
            }
            .onTapGesture {
                withAnimation {
                    filteredCalendar = nil
                }

            }
            ForEach(eventVM.calendars, id: \.calendarIdentifier) { calendar in
                ZStack {
                    if isCalendarSelected(calendar: calendar) {
                        Capsule()
                            .fill(Color(cgColor: calendar.cgColor))
                    } else {
                        Capsule()
                            .fill(Color(cgColor: calendar.cgColor).opacity(0.4))
                    }
                    Text(calendar.title)
                        .foregroundStyle(ESColor(cgColor: calendar.cgColor).isDarkColor ? Color.white : Color.black)
                        .multilineTextAlignment(.center)
                        .padding(.all, 5)
                }
                .onTapGesture {
                    withAnimation {
                        self.filteredCalendar = calendar
                    }
                }
            }
        }

    }

    func isCalendarSelected(calendar: EKCalendar) -> Bool {
        return calendar == filteredCalendar
    }
}

#Preview {
    EventFilterView(
        eventVM: .constant(
            .init(isDemo: true)
        ),
        filteredCalendar: .constant(
            .init(
                for: .event,
                eventStore: .init()
            )
        )
    )
}
