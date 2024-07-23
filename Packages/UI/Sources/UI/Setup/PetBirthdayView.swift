//
//  PetBirthdayView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

public struct PetBirthdayView: View {

    @Binding var birthday: Date
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)

    public var body: some View {
        VStack {
            Spacer()
            Text("birthday_title", bundle: .module)
                .font(.title2)
                .bold()
                .padding(.trailing, 20)
            DatePicker(
                "birthday_title",
                selection: $birthday,
                displayedComponents: .date
            )
                .labelsHidden()
                .tint(tintColor.color)
            Spacer()
        }
        .padding(.all)
    }
}

#Preview {
    PetBirthdayView(birthday: .constant(.now))
}
