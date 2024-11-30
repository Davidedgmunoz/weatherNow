//
//  NotificationsManager.swift
//  WeatherNow
//
//  Created by David Muñoz on 29/11/2024.
//

import Foundation
import UserNotifications

public protocol NotificationsManager {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func scheduleNotification(title: String, body: String, at date: Date)
    func scheduleImmediateNotification(title: String, body: String)
    func cancelAllNotifications()
    func cancelNotification(withIdentifier identifier: String)

}


public final class LocalNotificationsManager: NotificationsManager {
    private let notificationCenter = UNUserNotificationCenter.current()
    
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    public func scheduleNotification(title: String, body: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled with identifier: \(identifier)")
            }
        }
    }
    
    public func scheduleImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Configura el disparador con un intervalo de tiempo cercano a 0
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // Crea la solicitud
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Añade la notificación al centro de notificaciones
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled immediately with identifier: \(identifier)")
            }
        }
    }

    public func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    public func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
