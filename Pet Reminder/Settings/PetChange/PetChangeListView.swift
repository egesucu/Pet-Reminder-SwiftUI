//
//  PetChangeListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog

struct PetChangeListView: View {

    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.undoManager) var undoManager
    @AppStorage(Strings.tintColor) var tintColor = Color.accent

    @Query(sort: \Pet.name) var pets: [Pet]

    @State private var showUndoButton = false
    @State private var buttonTimer: Timer?
    @State private var time = 0
    @State private var isEditing = false
    @State private var selectedPet: Pet?
    @State private var showSelectedPet = false
    @State private var showEditButton = false
    @State private var notificationManager = NotificationManager()

    var body: some View {
        ScrollView {
            petList
                .onTapGesture {
                    Logger
                        .viewCycle
                        .info("Surface tapped.")
                    isEditing = false
                    Logger
                        .viewCycle
                        .info("Editing status: \(isEditing)")
                }
        }
            .toolbar {
                if showEditButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isEditing.toggle()
                        } label: {
                            Text(isEditing ? "Done" : "Edit")
                        }
                    }
                }
            }
            .navigationTitle(Text("Choose Friend"))
    }

    @ViewBuilder
    private var petList: some View {
        if pets.isEmpty {
            EmptyPageView(emptyPageReference: .petList)
        } else {
            LazyVGrid(columns: [.init(), .init()]) {
                ForEach(pets, id: \.name) { pet in
                    VStack {
                        if isEditing {
                            ZStack(alignment: .topTrailing) {
                                VStack {
                                    ESImageView(data: pet.image)
                                        .clipShape(Circle())
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 60)
                                                .stroke(
                                                    defineColor(pet: pet),
                                                    lineWidth: 5
                                                )
                                        )
                                        .wiggling()
                                    Text(pet.name)
                                }
                                Button {
                                    withAnimation {
                                        deletePet(pet: pet)
                                        isEditing = false
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(Color.red)
                                        .offset(x: 15, y: 0)
                                }

                            }
                        } else {
                            ESImageView(data: pet.image)
                                .clipShape(Circle())
                                .frame(width: 120, height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 60)
                                        .stroke(
                                            defineColor(pet: pet),
                                            lineWidth: 5
                                        )
                                )

                            Text(pet.name)
                        }

                    }
                    .onTapGesture {
                        selectedPet = pet
                        showSelectedPet.toggle()
                        Logger
                            .viewCycle
                            .info("PR: Pet Selected: \(selectedPet?.name ?? "")")
                    }
                    .sheet(isPresented: $showSelectedPet, onDismiss: {
                        selectedPet = nil
                    }, content: {
                        PetChangeView(pet: $selectedPet)
                            .presentationCornerRadius(25)
                            .presentationDragIndicator(.hidden)
                            .interactiveDismissDisabled()
                    })
                    .onLongPressGesture {
                        isEditing = true
                    }
                    .padding([.top, .leading])
                }
            }
        }

    }

    func deletePet(pet: Pet) {
        let tempPetName = pet.name
        if pet == selectedPet {
            selectedPet = nil
        }
        modelContext.delete(pet)
        showUndoButton.toggle()
        buttonTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if time == 10 {
                withAnimation {
                    self.notificationManager.removeAllNotifications(of: tempPetName)
                    showUndoButton = false
                    timer.invalidate()
                }
            } else {
                time += 1
            }
        })
    }

    private func defineColor(pet: Pet) -> Color {
        selectedPet?.name == pet.name ? Color.yellow : Color.clear
    }
}

#Preview {
    NavigationStack {
        PetChangeListView()
            .modelContainer(for: Pet.self)
    }

}
