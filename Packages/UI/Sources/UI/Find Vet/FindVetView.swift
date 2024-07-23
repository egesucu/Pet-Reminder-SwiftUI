//
//  FindVetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
import SharedModels
import OSLog

public struct FindVetView: View {

    @State private var viewModel = VetViewModel()
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)
    
    public init() {
        viewModel.searchText = String(localized: "default_vet_text", bundle: .module)
    }

    public var body: some View {
        NavigationStack {
            mapView
        }
        .navigationTitle(Text("find_vet_title", bundle: .module))
        .overlay {
            if viewModel.mapViewStatus == .locationNotAllowed {
                ContentUnavailableView {
                    Label {
                        Text("find_vet_error_title", bundle: .module)
                    } icon: {
                        Image(systemName: SFSymbols.locationAuthError)
                    }
                } description: {
                    Text("location_alert_context", bundle: .module)
                } actions: {
                    ESSettingsButton()
                }
            }
        }
        .task {
            await viewModel.requestMap()
        }
        .sheet(item: $viewModel.selectedLocation, onDismiss: {
            withAnimation {
                viewModel.selectedLocation = nil
            }
        }, content: { location in
            MapItemView(location: location)
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
                .padding(.horizontal)
        })
    }

    private var mapView: some View {
        Map(
            position: $viewModel.userLocation,
            selection: $viewModel.selectedLocation
        ) {
            ForEach(viewModel.searchedLocations) { location in
                Marker(
                    location.name,
                    systemImage: SFSymbols.pawprintCircleFill,
                    coordinate: location.coordinate
                )
                .tint(tintColor.color)
                .tag(location)
            }
            UserAnnotation()
        }
        .mapControls {
            MapPitchToggle()
            MapUserLocationButton()
            MapCompass()
        }
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search) {
            Task {
                do {
                    try await viewModel.searchPins()
                } catch let error {
                    Logger.vet.error("Error setting user location: \(error.localizedDescription)")
                }
            }
        }
        .disableAutocorrection(true)
    }
}

#Preview {
    FindVetView()
}
