//
//  NotificationManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import UserNotifications
import Observation
import OSLog

@Observable
class NotificationManager {

    var notifications: [UNNotificationRequest] = .empty
    let notificationCenter = UNUserNotificationCenter.current()

    func askPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
        } catch let error {
            print(error)
        }
        return false
    }

    func filterNotifications(of pet: Pet) -> [UNNotificationRequest] {
        notifications.filter { notification in
            Logger
                .viewCycle
                .info("Pet \(pet.wrappedName): notifications \(notification.identifier)")
            return notification.identifier.contains(pet.wrappedName)
        }
    }

    @Sendable
    func getNotifications() async {
        notifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    func changeNotificationTime(of petName: String, with date: Date, for type: NotificationType) {
        removeNotification(of: petName, with: type)
        Task {
            await createNotification(of: petName, with: type, date: date)
        }
    }

    func checkAllAppNotifications() async {
        notifications = await notificationCenter.pendingNotificationRequests()
    }

    func createNotifications(for pet: Pet) async {
        switch pet.selection {
        case .both:
            await createNotification(of: pet.wrappedName, with: .morning, date: pet.morningTime ?? .eightAM)
            await createNotification(of: pet.wrappedName, with: .evening, date: pet.eveningTime ?? .eightPM)
            await createNotification(of: pet.wrappedName, with: .birthday, date: pet.wrappedBirthday)
        case .morning:
            await createNotification(of: pet.wrappedName, with: .morning, date: pet.morningTime ?? .eightAM)
            await createNotification(of: pet.wrappedName, with: .birthday, date: pet.wrappedBirthday)
        case .evening:
            await createNotification(of: pet.wrappedName, with: .evening, date: pet.eveningTime ?? .eightPM)
            await createNotification(of: pet.wrappedName, with: .birthday, date: pet.wrappedBirthday)
        }
    }
}

// MARK: - ADD NOTIFICATIONS
extension NotificationManager {

    func createNotification(of petName: String, with type: NotificationType, date: Date) async {

        if await askPermission() {
            let content = UNMutableNotificationContent()
            content.title = String(localized: "notification_title")
            var dateComponents = DateComponents()
            let calendar = Calendar.current

            switch type {
            case .birthday:
                content.body = String(localized: "notification_birthday_content \(petName)")
                dateComponents.day = calendar.component(.day, from: date)
                dateComponents.month = calendar.component(.month, from: date)
                dateComponents.hour = 0; dateComponents.minute = 0; dateComponents.second = 0
            default:
                content.body = String(localized: "notification_content \(petName)")
                dateComponents.hour = calendar.component(.hour, from: date)
                dateComponents.minute = calendar.component(.minute, from: date)
            }

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: Strings.notificationIdenfier(
                    petName,
                    type.rawValue
                ),
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch let error {
                print(error)
            }

        }
    }
}

// MARK: - DELETING NOTIFICATIONS
extension NotificationManager {
    /// Checks all pending notifications that does not belong any registered pets and removes them.
    /// - Parameter names: Names of the registered pets.
    func removeOtherNotifications(beside names: [String]) async {

        var notifications = await notificationCenter.pendingNotificationRequests()

        for name in names {
            notifications = notifications.filter({ !$0.identifier.contains(name) })
        }

        let unknownIdentifiers = notifications.map(\.identifier)
        self.removeNotificationsIdentifiers(with: unknownIdentifiers)
    }

    func removeNotificationsIdentifiers(with identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func removeNotification(of petName: String, with type: NotificationType) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            Strings.notificationIdenfier(petName, type.rawValue)])
    }

    func removeAllNotifications(of petName: String?) {
        guard let name = petName else { return }
        let notifications = [
            Strings.notificationIdenfier(name, NotificationType.morning.rawValue),
            Strings.notificationIdenfier(name, NotificationType.evening.rawValue),
            Strings.notificationIdenfier(name, NotificationType.birthday.rawValue)
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notifications)
    }

    func removeAllDailyNotifications(of name: String?) {
        guard let name else { return }
        let notifications = [
            Strings.notificationIdenfier(name, NotificationType.morning.rawValue),
            Strings.notificationIdenfier(name, NotificationType.evening.rawValue)
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notifications)
    }

    func removeNotifications(pets: [Pet]) {
        notificationCenter.removeAllPendingNotificationRequests()
        for pet in pets {
            removeAllNotifications(of: pet.wrappedName)
        }
    }
}

extension Sequence {
    func filter(_ keyPath: KeyPath<Element, Bool>) -> [Element] {
        return self.filter { $0[keyPath: keyPath] }
    }
}
