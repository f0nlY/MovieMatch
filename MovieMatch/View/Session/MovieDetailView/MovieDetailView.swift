//
//  MovieDetailView.swift
//  MovieMatch
//
//  Created by Ilya on 28.05.2026.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: movie.fullPosterURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.myPink)
                                .overlay(ProgressView().tint(.myRed))
                        }
                        .frame(height: 500)
                        .clipped()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(movie.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.myRed)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", movie.voteAverage))
                                    .fontWeight(.bold)
                                    .foregroundColor(.myRed)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.myPink)
                            .cornerRadius(10)
                        }
                        
                        Text("\(movie.year) • \(movie.primaryGenre)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Описание")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.myRed)
                            .padding(.top, 10)
                        
                        Text(movie.overview.isEmpty ? "Описание отсутствует на русском языке." : movie.overview)
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        Button {
                            watchTrailer()
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Смотреть трейлер")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                LinearGradient(colors: [Color.pink, Color.myRed], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(15)
                            .shadow(color: Color.myRed.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private func watchTrailer() {
        let query = "\(movie.title) \(movie.year) трейлер"
        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.youtube.com/results?search_query=\(encodedQuery)") {
            UIApplication.shared.open(url)
        }
    }
}

