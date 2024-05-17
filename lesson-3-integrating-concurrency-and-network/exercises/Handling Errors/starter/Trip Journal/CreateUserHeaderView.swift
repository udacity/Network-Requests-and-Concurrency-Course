//
//  CreateUserHeaderView.swift
//  Trip Journal
//
//  Created by Mark DiFranco on 2024-05-16.
//

import SwiftUI

struct CreateUserHeaderView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 120))
                    .foregroundStyle(.tint)
                    .padding(.bottom)

                Text("Trip Journal")
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                Text("Create an Account")
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding(.bottom)
        .textCase(.none)
    }
}

#Preview {
    CreateUserHeaderView()
}
