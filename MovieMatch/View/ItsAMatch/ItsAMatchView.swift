//
//  ItsAMatchView.swift
//  MovieMatch
//
//  Created by Ilya on 28.05.2026.
//

import SwiftUI

struct MatchView: View {
    let movie: Movie
    let partnerName: String
    let userAvatarBase64: String?
    let partnerAvatarBase64: String?
    let userInitials: String
    let partnerInitials: String
    
    var onKeepSwiping: () -> Void
    
    @State private var animateAvatars = false
    @State private var showDetail = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 15) {
                Spacer(minLength: 10)
                
                VStack(spacing: 8) {
                    Text("У вас Мэтч! 🎉")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.myRed)
                        .multilineTextAlignment(.center)
                    
                    Text("Вы оба хотите посмотреть этот фильм с \(partnerName)!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                HStack(spacing: -15) {
                    avatarCircle(base64: userAvatarBase64, initials: userInitials)
                        .offset(x: animateAvatars ? 0 : -150)
                    
                    avatarCircle(base64: partnerAvatarBase64, initials: partnerInitials)
                        .offset(x: animateAvatars ? 0 : 150)
                }
                .padding(.vertical, 5)
                
                AsyncImage(url: movie.fullPosterURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.myPink.opacity(0.2))
                        .overlay(ProgressView().tint(.myRed))
                }
                .frame(width: 210, height: 315)
                .cornerRadius(16)
                .clipped()
                .shadow(color: Color.myRed.opacity(0.5), radius: 15, x: 0, y: 8)
                .onTapGesture {
                    showDetail = true
                }
                
                Text(movie.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 10)
                
                VStack(spacing: 12) {
                    Button {
                        watchTrailer()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Смотреть трейлер")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(colors: [Color.pink, Color.myRed], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.myRed.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    
                    Button {
                        onKeepSwiping()
                    } label: {
                        Text("Продолжить поиск")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 25)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateAvatars = true
            }
        }
        .sheet(isPresented: $showDetail) {
            MovieDetailView(movie: movie)
        }
    }
    
    private func avatarCircle(base64: String?, initials: String) -> some View {
        Group {
            if let b64 = base64, !b64.isEmpty,
               let data = Data(base64Encoded: b64),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [Color.pink, Color.myRed],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Text(initials.isEmpty ? "?" : initials)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                )
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.myRed, lineWidth: 3))
        .shadow(color: Color.myRed.opacity(0.4), radius: 8)
    }
    
    private func watchTrailer() {
        let query = "\(movie.title) \(movie.year) трейлер"
        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.youtube.com/results?search_query=\(encodedQuery)") {
            UIApplication.shared.open(url)
        }
    }
}
