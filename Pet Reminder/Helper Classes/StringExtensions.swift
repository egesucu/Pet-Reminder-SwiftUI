//
//  StringExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

struct Strings {
    internal static let demoPets = [
        "Viski", "Dolly", "Mısır", "Boncuk",
        "Pop", "Rocky", "Bunny", "Spur", "Lully",
        "Baggy"
    ]
    internal static let demoVaccines = ["Pulvarin", "Alvarin", "Gagarin", "Aclor", "Silverin", "Volverine"]
    internal static let placeholderVaccine = "Pulvarin"
    internal static let demo = "Demo"
    internal static let petSaved = "petSaved"
    internal static let tintColor = "tint_color"
    internal static let doggo = "Doggo"
    internal static let viski = "Viski"
    internal static let donateTeaID = "pet_reminder_tea_donate"
    internal static let donateFoodID = "pet_reminder_food_donate"

    internal static func footerLabel(_ first: Any) -> String {
        return "© Ege Sucu \(first)"
    }
    internal static func notificationIdenfier(_ first: Any, _ second: Any) -> String {
      return "\(first)-\(second)-notification"
    }

    internal static func demoEvent(_ first: Any) -> String {
        return "Demo Event \(first)"
    }

    internal static let petReminder = "Pet Reminder"

}

internal enum SFSymbols {
    internal static let pawPrint = "pawprint"
    internal static let sun = "Sun"
    internal static let xmarkSealFill = "xmark.seal.fill"
    internal static let pawprintCircleFill = "pawprint.circle.fill"
    internal static let xcircleFill = "x.circle.fill"
    internal static let person = "person.crop.circle"
    internal static let personSelected = "person.crop.circle.fill"
    internal static let list = "list.bullet"
    internal static let listSelected = "list.bullet.indent"
    internal static let map = "map"
    internal static let mapSelected = "map.fill"
    internal static let settings = "gearshape"
    internal static let settingsSelected = "gearshape.fill"
    internal static let calendar = "calendar.badge.plus"
    internal static let morning = "sun.max.circle.fill"
    internal static let evening = "moon.stars.circle.fill"
    internal static let birthday = "birthday.cake.fill"
    internal static let close = "xmark.circle.fill"
    internal static let add = "plus.circle.fill"
    internal static let vaccine = "syringe.fill"
    internal static let eveningToggle = "moon.circle"
    internal static let eveningToggleSelected = "moon.circle.fill"
    internal static let checked = "checkmark.square"
    internal static let notChecked = "square"
    internal static let morningToggle = "sun.max.circle"
    internal static let morningToggleSelected = "sun.max.circle.fill"

}

extension String {
    static func formatEventDateTime(current: Bool, allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return current ? String(
                localized: "all_day_title"
            ) : String.futureDateTimeFormat(
                allDay: allDay,
                event: event
            )
        } else {
            return current ? String.currentDateTimeFormat(
                allDay: allDay,
                event: event
            ) : String.futureDateTimeFormat(
                allDay: allDay,
                event: event
            )
        }
    }

    static func futureDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return "\(event.startDate.printDate()) \(String(localized: "all_day_title"))"
        } else {
            return "\(event.startDate.printDate()) \(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }

    static func currentDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return String(localized: "all_day_title")
        } else {
            return "\(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }

    var isNotEmpty: Bool {
        !self.isEmpty
    }
}

extension LocalizedStringKey {
    static let save: Self = "save"
    static let cancel: Self = "cancel"
}
