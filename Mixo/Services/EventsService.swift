//
//  EventsService.swift
//  Mixo
//
//  Created by Alexander Lisovik on 13.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

/// Any event type that can be fired through EventsService
public protocol EventType {
    associatedtype ValueType
    var name: NSNotification.Name { get }
}

// Generic struct describing name of an event and its value type. Should be used as default way to create EventType objects
public struct Event<T>: EventType {
    public typealias ValueType = T
    public let name: NSNotification.Name

    public init(name: NSNotification.Name? = nil) {
        guard let name = name else {
            // Make sure the event is statically/globally created, as UUID as notification name must remain the same during the whole session
            self.name = NSNotification.Name(rawValue: UUID().uuidString)
            return
        }
        self.name = name
    }
}

public final class EventsService {
    public static let `default` = EventsService()

    public var enableLogging: Bool?

    // Used for cleaning up observers when registered owners are deallocated from memory
    private struct ObserverHolder {
        weak var owner: AnyObject?
        let observer: NSObjectProtocol
        let eventName: String
    }

    private var observerHolders: [ObserverHolder]
    private let notificationCenter: NotificationCenter
    private let operationQueue: OperationQueue
    private let synchronizationQueue: DispatchQueue

    /// NotificationCenterEventsService
    ///
    /// - Parameters:
    ///   - notificationCenter: NotificationCenter instance to be used as backbone to event service
    ///   - operationQueue: OperationQueue in which the triggered events will be called
    ///   - synchronizeQueue: DispatchQueue used to synchronize read/write of observer references, so clean up can be *thread-safe*
    public init(notificationCenter: NotificationCenter = NotificationCenter.default,
                operationQueue: OperationQueue = OperationQueue.main,
                synchronizationQueue: DispatchQueue = DispatchQueue(label: "home24.eventsservice.syncqueue", attributes: .concurrent)) {
        self.notificationCenter = notificationCenter
        self.operationQueue = operationQueue
        self.synchronizationQueue = synchronizationQueue
        self.observerHolders = []
    }

    /// Registers an observer for a specified eventType, with an expected event value
    ///
    /// - Parameters:
    ///   - owner: Object that will be observing the event
    ///   - eventType: The specific type of the event that will be observed
    ///   - handler: block invoked when an event of `eventType` is fired by someone. Contains an value passed during event firing
    public func register<E: EventType>(_ owner: AnyObject, for eventType: E, handler: @escaping (E.ValueType) -> Void) {
        log("\(type(of: owner)) registered for event: \(eventType)")
        let observer = notificationCenter.addObserver(forName: eventType.notificationName,
                                                      object: nil,
                                                      queue: operationQueue,
                                                      using: { [weak owner] notification in
                                                          guard let observedValue = notification.object as? E.ValueType else {
                                                              return
                                                          }
                                                          self.log("\(type(of: owner)) notified of event: \(eventType) with value: \(observedValue)")
                                                          handler(observedValue)
                                                      })
        addObserverOwner(owner: owner, observer: observer, eventName: eventType.name.rawValue)
    }

    /// Posts an event and notifies interested observers
    ///
    /// - Parameters:
    ///   - eventType: The specific type of the event that will be fired
    ///   - value: A possible value to be send inside the event to the observers
    public func post<E: EventType>(eventType: E, value: E.ValueType) {
        log("event: \(eventType) posted")
        cleanUpObservers()
        notificationCenter.post(name: eventType.notificationName, object: value)
    }

    public func post<E: EventType>(eventType: E) where E.ValueType == Void {
        post(eventType: eventType, value: ())
    }
}

// MARK: - Private
extension EventsService {
    private func addObserverOwner(owner: AnyObject, observer: NSObjectProtocol, eventName: String) {
        synchronizationQueue.async(flags: .barrier) {
            // An observer must be unique for a specific event. Clear up to avoid duplications before adding the new one
            let previousObservers = self.observerHolders.filter { $0.owner === owner && $0.eventName == eventName }
            for observerHolder in previousObservers {
                self.notificationCenter.removeObserver(observerHolder.observer)
                self.observerHolders.removeAll(where: { $0.eventName == observerHolder.eventName && observerHolder.owner === $0.owner })
            }

            self.observerHolders.append(ObserverHolder(owner: owner, observer: observer, eventName: eventName))
        }
    }

    private func cleanUpObservers() {
        // Removing observers in which the holder was already deallocated
        synchronizationQueue.async(flags: .barrier) {
            for (index, observerHolder) in self.observerHolders.enumerated().reversed() where observerHolder.owner == nil {
                self.log("Observer with deallocated owner cleared")
                self.notificationCenter.removeObserver(observerHolder.observer)
                self.observerHolders.remove(at: index)
            }
        }
    }

    private func log(_ message: String) {
        guard let enableLogging = enableLogging, enableLogging == true else {
            return
        }
        print(message)
    }
}

private extension EventType {
    var notificationName: Notification.Name {
        return name
    }
}
