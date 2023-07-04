//
//  HomeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.12.2020.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import EventKit

struct HomeView: View {

    @Environment(\.modelContext)
    private var viewContext

    @Query var pets: [Pet]
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    @State private var addPet = false

    var body: some View {

        NavigationView {

            VStack {
                if pets.count > 0 {
                    List {
                        ForEach(pets, id: \.name) { pet in
                            NavigationLink {
                                PetDetailView(pet: pet)
                            } label: {
                                PetCell(pet: pet)
                            }
                        }
                        .onDelete(perform: delete)
                        .navigationTitle("pet_name_title")
                    }
                    .listStyle(.insetGrouped)
                    .sheet(isPresented: $addPet, onDismiss: {

                    }, content: {
                        AddPetView()
                    })
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.addPet.toggle()
                            }, label: {
                                Label("add_animal_accessible_label", systemImage: SFSymbols.add)
                                    .foregroundColor(.accentColor)
                                    .font(.title)
                            })
                        }
                })
                } else {
                    Text("pet_no_pet")
                }
            }
            .navigationTitle("pet_name_title")
            Text("pet_select")
        }.navigationViewStyle(.stack)

    }

    func delete(at offsets: IndexSet) {

        for index in offsets {
            let pet = pets[index]
            viewContext.delete(pet)
        }

    }
}

struct HomeViewPreview: PreviewProvider {

    static var previews: some View {
        HomeView()
    }
}
