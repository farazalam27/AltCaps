//
//  ContentView.swift
//  AlternatingCapsHost
//
//  Created by Faraz Alam on 5/5/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Image("speechBubbleIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Text("AltCaps is an iMessage app.\nOpen Messages to use it!")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    ContentView()
}
