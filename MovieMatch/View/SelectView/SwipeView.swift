//
//  SwipeView.swift
//  MovieMatch
//
//  Created by Ilya on 23.05.2026.
//

import SwiftUI

struct SwipeView: View {

    @State private var cardOffset: CGSize = .zero
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var userManager = UserManager()
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var matchedMovie: Movie? = nil
    @State private var swipedHistory: [Movie] = []
    @State private var selectedMovie: Movie? = nil

    var partnerImage: UIImage? {
        guard let b64 = sessionViewModel.partnerAvatarBase64, !b64.isEmpty,
              let data = Data(base64Encoded: b64) else { return nil }
        return UIImage(data: data)
    }

    var partnerInitials: String {
        guard let name = sessionViewModel.partnerName, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ").map { String($0.prefix(1)).uppercased() }
        return parts.count >= 2 ? parts[0] + parts[1] : String(name.prefix(2)).uppercased()
    }

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text(sessionViewModel.isSessionActive ? "Совместный поиск" : "Соло поиск")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.myRed)
                    
                    Spacer()
                    
                    if sessionViewModel.isSessionActive {
                        Button {
                            sessionViewModel.leaveSession()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.myRed)
                                .clipShape(Circle())
                                .shadow(color: Color.myRed.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                .padding(.bottom, 15)
                .zIndex(10)

                Group {
                    if let firstMovie = networkManager.movies.first {
                        CardView(movie: firstMovie)
                            .onTapGesture {
                                selectedMovie = firstMovie
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.myPink)
                            .frame(maxWidth: .infinity, maxHeight: 450)
                            .overlay(ProgressView("Ищем фильмы...").foregroundColor(.myRed))
                    }
                }
                .padding(.horizontal)
                .SwipeFunction(offset: $cardOffset) {
                    handleSwipeRight()
                } onSwipeLeft: {
                    handleSwipeLeft()
                } onSwipeUp: {
                    handleSwipeUp()
                }
                .zIndex(1)

                HStack(spacing: 25) {
                    SvipeView(
                        actionLeft: { swipeCardFromButton(x: -500, y: 0, isRight: false, isUp: false) },
                        actionMiddle: { swipeCardFromButton(x: 0, y: -800, isRight: false, isUp: true) },
                        actionRight: { swipeCardFromButton(x: 500, y: 0, isRight: true, isUp: false) }
                    )
                }
                .padding(.top, 10)

                Spacer()

                if sessionViewModel.isSessionActive {
                    HStack(spacing: 15) {
                        if let img = partnerImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.myRed, lineWidth: 2))
                        } else {
                            Circle()
                                .fill(Color.myRed)
                                .frame(width: 45, height: 45)
                                .overlay(
                                    Text(partnerInitials)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(sessionViewModel.partnerName ?? "Партнёр")
                                .foregroundColor(.myRed)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 6) {
                                Text("Последние:")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 5) {
                                    ForEach(0..<5, id: \.self) { index in
                                        if index < sessionViewModel.partnerRecentActions.count {
                                            Circle()
                                                .fill(colorForAction(sessionViewModel.partnerRecentActions[index]))
                                                .frame(width: 8, height: 8)
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.myPink)
                    .cornerRadius(20)
                    .shadow(color: Color.myRed.opacity(0.1), radius: 5, x: 0, y: 5)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            userManager.loadUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if networkManager.movies.isEmpty { fetchMoviesLogic() }
            }
        }
        .onChange(of: userManager.selectedGenres) { _, genres in
            if !sessionViewModel.isSessionActive {
                networkManager.resetAndFetch(genres: genres, isSolo: true)
            }
        }
        .onChange(of: sessionViewModel.isSessionActive) { _, isActive in
            if isActive {
                networkManager.resetAndFetch(genres: Array(sessionViewModel.sessionGenres), isSolo: false)
            } else {
                networkManager.resetAndFetch(genres: userManager.selectedGenres, isSolo: true)
            }
        }
        .onChange(of: sessionViewModel.newlyMatchedMovieId) { _, matchedId in
            guard let matchedId = matchedId else { return }
            
            if let movie = networkManager.movies.first(where: { $0.id == matchedId }) ??
                           swipedHistory.first(where: { $0.id == matchedId }) {
                
                userManager.incrementMatches()
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    self.matchedMovie = movie
                }
                sessionViewModel.newlyMatchedMovieId = nil
            }
        }
        .alert("Сессия завершена", isPresented: $sessionViewModel.showPartnerLeftAlert) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text("Ваш партнёр покинул сессию.\nВы переведены в соло-режим.")
        }
        
        .fullScreenCover(item: $matchedMovie) { movie in
            MatchView(
                movie: movie,
                partnerName: sessionViewModel.partnerName ?? "Партнёр",
                userAvatarBase64: userManager.avatarBase64,
                partnerAvatarBase64: sessionViewModel.partnerAvatarBase64,
                userInitials: userManager.initials,
                partnerInitials: partnerInitials,
                onKeepSwiping: {
                    self.matchedMovie = nil
                }
            )
        }
        
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie)
        }
    }
    
    private func colorForAction(_ action: String) -> Color {
        switch action {
        case "like": return .green
        case "dislike": return .red
        case "favorite": return .yellow
        default: return .gray
        }
    }

    private func handleSwipeRight() {
        userManager.incrementSwipes()
        
        if let currentMovie = networkManager.movies.first {
            swipedHistory.append(currentMovie)
            if sessionViewModel.isSessionActive {
                sessionViewModel.trackMovieMetadata(movie: currentMovie)
                sessionViewModel.likeMovie(movieId: currentMovie.id)
            }
        }
        nextMovie()
    }
    
    private func handleSwipeLeft() {
        userManager.incrementSwipes()
        if let currentMovie = networkManager.movies.first {
            swipedHistory.append(currentMovie)
            if sessionViewModel.isSessionActive {
                sessionViewModel.trackMovieMetadata(movie: currentMovie)
                sessionViewModel.dislikeMovie(movieId: currentMovie.id)
            }
        }
        nextMovie()
    }
    
    private func handleSwipeUp() {
        userManager.incrementSwipes()
        if let currentMovie = networkManager.movies.first {
            swipedHistory.append(currentMovie)
            if sessionViewModel.isSessionActive {
                sessionViewModel.trackMovieMetadata(movie: currentMovie)
                sessionViewModel.favoriteMovie(movieId: currentMovie.id)
            }
        }
        nextMovie()
    }

    private func swipeCardFromButton(x: CGFloat, y: CGFloat, isRight: Bool, isUp: Bool) {
        cardOffset = CGSize(width: x, height: y)
        if isRight { handleSwipeRight() }
        else if isUp { handleSwipeUp() }
        else { handleSwipeLeft() }
    }

    private func nextMovie() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                if !networkManager.movies.isEmpty {
                    networkManager.movies.removeFirst()
                }
            }
            cardOffset = .zero
            if networkManager.movies.count < 5 { fetchMoviesLogic() }
        }
    }

    private func fetchMoviesLogic() {
        if sessionViewModel.isSessionActive {
            networkManager.fetchMovies(genres: Array(sessionViewModel.sessionGenres), isSolo: false)
        } else {
            networkManager.fetchMovies(genres: userManager.selectedGenres, isSolo: true)
        }
    }
}
