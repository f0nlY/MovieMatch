//
//  TrendingMovies.swift
//  MovieMatch
//
//  Created by Ilya on 28.05.2026.
//

import SwiftUI

struct TrendingMovies: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var selectedMovie: Movie? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔥 Тренды сегодня")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.myRed)
                .padding(.horizontal, 25)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(networkManager.movies.prefix(7)) { movie in
                        Button {
                            selectedMovie = movie
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: movie.fullPosterURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.myPink)
                                            .overlay(ProgressView().tint(.myRed))
                                    }
                                    .frame(width: 90, height: 135)
                                    .cornerRadius(12)
                                    .clipped()
                                    
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 10))
                                        Text(String(format: "%.1f", movie.voteAverage))
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(6)
                                    .padding(6)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(movie.title)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.myRed)
                                        .lineLimit(1)
                                        .frame(width: 90, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(movie.primaryGenre)
                                        .font(.system(size: 9))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 25)
            }
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie)
        }
    }
}
