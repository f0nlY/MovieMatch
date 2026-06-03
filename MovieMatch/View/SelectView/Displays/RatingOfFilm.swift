//
//  ratingOfFilm.swift
//  MovieMatch
//
//  Created by Ilya on 24.05.2026.
//

import SwiftUI

struct RatingOfFilm: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("8.6")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
            Spacer()
        }
    }
}

#Preview {
    RatingOfFilm()
}
