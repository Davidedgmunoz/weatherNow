//
//  DefaultLocation.swift
//  WeatherNow
//
//  Created by David Muñoz on 28/11/2024.
//

import Combine
import Foundation
import Loadable
import OSLog

public final class Location: Loadable, LocationProtocol {
    private let api: API.ClientsAPI.Location&API.ClientsAPI.Weather
    private let persistenceManager: LocationPersistenceManager
    init(
        api: API.ClientsAPI.Location&API.ClientsAPI.Weather,
        persistenceManager: LocationPersistenceManager
    ) {
        self.persistenceManager = persistenceManager
        self.api = api
    }
    
    public var locations: [any LocationItem] { _locations }
    private var _locations: [DefaultLocationItem] = []
    
    fileprivate var selectedItem: DefaultLocationItem? {
        willSet {
            selectedItem?.unselect()
        }
    }
    
    // we just load locations when they are empty
    // otherwise we can handle them in memory
    public override var needsSync: Bool { persistenceManager.items.isEmpty }
    
    private var cancellable: AnyCancellable?
    public override func doSync() {
        startSyncing()
        cancellable = persistenceManager.objectWillChange.sink {
            [weak self] in self?.locationsUpdated()
        }
        persistenceManager.syncIfNeeded()
        locationsUpdated()
    }
    
    private lazy var onSelect: ((DefaultLocationItem) -> Void)? = { [weak self] item in
        self?.selectedItem = item
    }
    
    private func locationsUpdated() {
        guard persistenceManager.state == .didSuccess else { return }
        _locations = persistenceManager.items.map { DefaultLocationItem(raw: $0, api: api, onSelect: onSelect) }
        
        if let selected = selectedItem,
           let matchingItem = _locations.first(where: { $0.id == selected.id }) {
            matchingItem.select()
        } else if let firstItem = _locations.first {
            firstItem.select()
        }
        
        state = .didSuccess
    }
    
    public func addUsersLocation(latitude: Double, longitude: Double) {
        Task {
            try? await findLocation(
                latitude: latitude,
                longitude: longitude,
                isUsersLocation: true
            )?.save()
        }
    }

    public func findLocation(latitude: Double, longitude: Double) async -> LocationItem? {
        guard state != .syncing else { return nil }
        startSyncing()
        do {
            let item = try await findLocation(
                latitude: latitude,
                longitude: longitude,
                isUsersLocation: false
            )
            state = .idle
            return item
        } catch {
            state = .idle
            return nil
        }
    }
    
    private func findLocation(
        latitude: Double, longitude: Double, isUsersLocation: Bool
    ) async throws  -> LocationItem? {
        let result = try await api.getLocation(fromLat: latitude, andLon: longitude)
        guard var raw = result.first else { return nil }
        return DefaultLocationItem(
            raw: raw,
            api: api,
            onSave: { [weak self] item in
                guard let self,
                      !self._locations.contains(item)
                else { return }
                raw.updateSavedAt()
                if isUsersLocation {
                    raw.markAsUsersLocation()
                    if self._locations.first?.isUserLocation ?? false {
                        self._locations.removeFirst()
                    }
                    self._locations.insert(item, at: 0)
                } else {
                    self._locations.append(item)
                }
                
                self.persistenceManager.save(raw)
                notifyDataDidChanged()
            },
            onSelect: onSelect
        )

    }
}
