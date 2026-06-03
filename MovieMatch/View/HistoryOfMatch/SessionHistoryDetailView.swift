//
//  SessionHistoryDetailView.swift
//  MovieMatch
//
//  Created by Ilya on 31.05.2026.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SessionHistoryDetailView: View {
    let session: CompletedSession
    @Environment(\.dismiss) var dismiss
    @State private var selectedMovie: Movie? = nil
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Карта сессии")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.myRed)
                        Text("Показаны все совместные решения")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.myRed)
                            .frame(width: 36, height: 36)
                            .background(Color.myPink)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                let data = session.data
                let currentUid = Auth.auth().currentUser?.uid ?? ""
                let hostId = data["hostId"] as? String ?? ""
                let isHost = currentUid == hostId
                
                let hostLikes = data["hostLikes"] as? [Int] ?? []
                let guestLikes = data["guestLikes"] as? [Int] ?? []
                let hostDislikes = data["hostDislikes"] as? [Int] ?? []
                let guestDislikes = data["guestDislikes"] as? [Int] ?? []
                let hostFavorites = data["hostFavorites"] as? [Int] ?? []
                let guestFavorites = data["guestFavorites"] as? [Int] ?? []
                
                let moviesMetadata = data["moviesMetadata"] as? [String: [String: Any]] ?? [:]
                
                if moviesMetadata.isEmpty {
                    VStack {
                        Spacer()
                        Text("В этой сессии не было сделано свайпов")
                            .foregroundColor(.gray)
                            .italic()
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(moviesMetadata.keys.sorted(), id: \.self) { movieIdStr in
                                if let idInt = Int(movieIdStr), let movieData = moviesMetadata[movieIdStr] {
                                    
                                    let title = movieData["title"] as? String ?? "Кино"
                                    let posterPath = movieData["posterPath"] as? String ?? ""
                                    
                                    let myAction = getActionText(
                                        movieId: idInt,
                                        isMeHost: isHost,
                                        hostLikes: hostLikes, guestLikes: guestLikes,
                                        hostDislikes: hostDislikes, guestDislikes: guestDislikes,
                                        hostFavorites: hostFavorites, guestFavorites: guestFavorites
                                    )
                                    
                                    let partnerAction = getActionText(
                                        movieId: idInt,
                                        isMeHost: !isHost,
                                        hostLikes: hostLikes, guestLikes: guestLikes,
                                        hostDislikes: hostDislikes, guestDislikes: guestDislikes,
                                        hostFavorites: hostFavorites, guestFavorites: guestFavorites
                                    )
                                    
                                    let isMatch = isAMatch(movieId: idInt, hostLikes: hostLikes, guestLikes: guestLikes)
                                    
                                    movieHistoryCard(
                                        title: title,
                                        posterPath: posterPath,
                                        myAction: myAction,
                                        partnerAction: partnerAction,
                                        isMatch: isMatch
                                    )
                                    .onTapGesture {
                                        let reconstructedMovie = Movie(
                                            id: idInt,
                                            title: title,
                                            overview: movieData["overview"] as? String ?? "Описание отсутствует.",
                                            posterPath: posterPath.isEmpty ? nil : posterPath,
                                            voteAverage: movieData["voteAverage"] as? Double ?? 0.0,
                                            releaseDate: movieData["releaseDate"] as? String ?? "",
                                            originalLanguage: movieData["originalLanguage"] as? String ?? "ru",
                                            genreIds: movieData["genreIds"] as? [Int] ?? []
                                        )
                                        self.selectedMovie = reconstructedMovie
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie)
        }
    }
    
    private func movieHistoryCard(title: String, posterPath: String, myAction: String, partnerAction: String, isMatch: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if !posterPath.isEmpty, let url = URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)") {
                    AsyncImage(url: url) { img in
                        img
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.myPink)
                            .overlay(ProgressView().tint(.myRed))
                    }
                    .frame(height: 220)
                    .cornerRadius(14)
                    .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.myPink)
                        .frame(height: 220)
                        .overlay(Image(systemName: "film").font(.largeTitle).foregroundColor(.myRed))
                }
                
                if isMatch {
                    Text("МЭТЧ 🎉")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.myRed)
                        .cornerRadius(8)
                        .padding(8)
                        .shadow(color: Color.myRed.opacity(0.4), radius: 4)
                }
            }
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Вы: \(myAction)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text("Партнёр: \(partnerAction)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
    
    private func getActionText(
        movieId: Int,
        isMeHost: Bool,
        hostLikes: [Int], guestLikes: [Int],
        hostDislikes: [Int], guestDislikes: [Int],
        hostFavorites: [Int], guestFavorites: [Int]
    ) -> String {
        let likes = isMeHost ? hostLikes : guestLikes
        let dislikes = isMeHost ? hostDislikes : guestDislikes
        let favorites = isMeHost ? hostFavorites : guestFavorites
        
        if favorites.contains(movieId) { return "Суперлайк ⭐" }
        if likes.contains(movieId) { return "Лайк ❤️" }
        if dislikes.contains(movieId) { return "Дизлайк ❌" }
        return "Пропущено 🔘"
    }
    
    private func isAMatch(movieId: Int, hostLikes: [Int], guestLikes: [Int]) -> Bool {
        return hostLikes.contains(movieId) && guestLikes.contains(movieId)
    }
}
