//
//  CardView.swift
//  MovieMatch
//
//  Created by Ilya on 24.05.2026.
//

import SwiftUI

struct CardBadge: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
}

struct CardView: View {
    let movie: Movie
    
    var badges: [CardBadge] {
        var result: [CardBadge] = []
        
        if movie.voteAverage >= 8.2 {
            result.append(CardBadge(text: "Топ 🔥", color: .myRed))
        }
        
        if let year = Int(movie.year), year >= 2023 {
            result.append(CardBadge(text: "Новинка ✨", color: .orange))
        }
        
        let mainGenre = movie.primaryGenre
        result.append(CardBadge(text: mainGenre, color: .purple))
        
        if let genreIds = movie.genreIds, genreIds.count > 1 {
            let secondGenreId = genreIds[1]
            if let secondGenreName = Movie.genreDictionary[secondGenreId], secondGenreName != mainGenre {
                result.append(CardBadge(text: secondGenreName, color: .indigo))
            }
        }
        
        return result
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: movie.fullPosterURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Color.myPink
                    ProgressView().tint(.myRed)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 450)
            .cornerRadius(25)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text("\(movie.year) • Рейтинг: \(String(format: "%.1f", movie.voteAverage))")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.9))
                
                HStack(spacing: 8) {
                    ForEach(badges.prefix(3)) { badge in
                        Text(badge.text)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(badge.color)
                            .clipShape(Capsule())
                            .shadow(color: badge.color.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.top, 2)
            }
            .padding(25)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [Color.black.opacity(0.95), Color.clear], startPoint: .bottom, endPoint: .top))
            .cornerRadius(25)
        }
        .contentShape(Rectangle())
    }
}
