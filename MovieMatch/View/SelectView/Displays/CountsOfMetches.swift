//
//  CountsOfMetches.swift
//  MovieMatch
//
//  Created by Ilya on 24.05.2026.
//

import SwiftUI

struct CountsOfMetches: View {
    var count: Int = 0
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundColor(.myRed)
            VStack(spacing: 0) {
                Text("\(count)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.myRed)
                Text("мэтчей")
                    .font(.callout)
                    .foregroundStyle(Color.myRed)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color.myPink)
        .clipShape(Capsule())
        .shadow(color: Color.myRed.opacity(0.15), radius: 5, x: 0, y: 3)
    }
}
