//
//  PetChangeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import SharedModels

public struct PetChangeView: View {

    @Binding var pet: Pet?
    @Environment(\.modelContext) var modelContext
    @State private var selectedImageData: Data?
    @Environment(\.dismiss) var dismiss
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)
    @State private var viewModel = PetChangeViewModel()

    public var body: some View {
        NavigationStack {
            if let pet {
                VStack {
                    ScrollView {
                        HStack {
                            if let outputImageData = viewModel.outputImageData,
                               let selectedImage = UIImage(data: outputImageData) {
                                PetShowImageView(selectedImage: selectedImage, onImageDelete: viewModel.removeImage)
                                    .padding(.horizontal)
                            } else {
                                Image(.defaultAnimal)
                                    .frame(width: 200, height: 200)
                            }
                            if !viewModel.defaultPhotoOn {
                                PhotoImagePickerView(photoData: $viewModel.outputImageData)
                                    .padding(.vertical)
                            }
                        }
                        Toggle(isOn: $viewModel.defaultPhotoOn) {
                            Text("default_photo_label", bundle: .module)
                        }
                        .tint(Color.accentColor)
                        .onChange(of: viewModel.defaultPhotoOn, {
                            if viewModel.defaultPhotoOn {
                                viewModel.outputImageData = nil
                            }
                        })
                        .padding()
                        Text("photo_upload_detail_title", bundle: .module)
                            .font(.footnote)
                            .foregroundStyle(Color(.systemGray2))
                            .multilineTextAlignment(.center)
                            .padding()
                        Form {
                            Section {
                                TextField(text: $viewModel.nameText) {
                                    Text("tap_to_change_text", bundle: .module)
                                }
                                DatePicker(selection: $viewModel.birthday, displayedComponents: .date) {
                                    Text("birthday_title", bundle: .module)
                                }
                            }
                            Section {
                                pickerView
                                setupPickerView()
                            }
                        }
                        .frame(height: 400)
                    }
                }
                .navigationTitle(pet.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                await viewModel.savePet(pet: pet)
                            }
                            dismiss()
                        } label: {
                            Text("Save", bundle: .module)
                                .bold()
                        }
                        .tint(tintColor.color)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel", bundle: .module)
                                .bold()
                        }
                        .tint(Color(uiColor: .systemRed))
                    }
                }
                .task {
                    await viewModel.getPetData(pet: pet)
                }
            }
        }
    }
    var pickerView: some View {
        VStack {
            Picker(selection: $viewModel.selection) {
                Text("feed_selection_both", bundle: .module)
                    .tag(FeedSelection.both)
                Text("feed_selection_morning", bundle: .module)
                    .tag(FeedSelection.morning)
                Text("feed_selection_evening", bundle: .module)
                    .tag(FeedSelection.evening)
            } label: {
                Text("feed_time_title")
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    func setupPickerView() -> some View {
        switch viewModel.selection {
        case .both:
            morningView
            eveningView
        case .morning:
            morningView
        case .evening:
            eveningView
        }
    }

    var eveningView: some View {
        DatePicker(
            selection: $viewModel.eveningDate,
            displayedComponents: .hourAndMinute
        ) {
            Text("feed_selection_evening", bundle: .module)
        }
    }

    var morningView: some View {
        DatePicker(
            selection: $viewModel.morningDate,
            displayedComponents: .hourAndMinute
        ) {
            Text("feed_selection_morning", bundle: .module)
        }
    }

}

#Preview {
    PetChangeView(pet: .constant(.preview))
        .modelContainer(DataController.previewContainer)
}
