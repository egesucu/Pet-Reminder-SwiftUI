//
//  ESImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct ESImageView: View {

    var data: Data?
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        if let data = data,
        let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(25)
                .shadow(radius: 10)
                .padding(5)
        } else {
            ZStack {
                Rectangle()
                    .fill(Color.accentColor)
                    .cornerRadius(25)
                    .shadow(radius: 10)

                Image(.defaultAnimal)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            }
        }
    }
}

struct ESImageView_Previews: PreviewProvider {
    static var previews: some View {
        ESImageView()
    }
}
