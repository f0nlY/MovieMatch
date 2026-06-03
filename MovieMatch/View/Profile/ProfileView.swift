//
//  ProfileView.swift
//  MovieMatch
//
//  Created by Ilya on 18.04.2026.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var currentScreen: AppScreen
    @StateObject private var userManager = UserManager()
    @State private var showSettings = false
    @State private var showGenreEdit = false

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {

                    HStack {
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 10)

                    HStack(spacing: 20) {
                        AvatarView(
                            userManager: userManager,
                            size: 100,
                            showEditButton: true,
                        )
                        .onTapGesture {
                            showSettings = true
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(userManager.username.isEmpty ? "Загрузка..." : userManager.username)
                                .foregroundColor(.myRed)
                                .fontWeight(.bold)
                                .font(.system(size: 26))
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)

                            Text(userManager.email.isEmpty ? "" : "@\(userManager.email.components(separatedBy: "@").first ?? "")")
                                .foregroundColor(.gray)
                                .font(.subheadline)

                            Button { showSettings = true } label: {
                                Text("Изменить")
                                    .foregroundColor(.myRed)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 14))
                            }
                            .frame(width: 100, height: 30)
                            .background(Color.myPink)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.myRed.opacity(0.4), lineWidth: 1.5))
                            .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)

                    HStack(spacing: 12) {
                        statBlock(value: "\(userManager.matchesCount)",  label: "Мэтчей",  color: .myRed)
                        statBlock(value: "\(userManager.sessionsCount)", label: "Сессий",  color: .orange)
                        statBlock(value: "\(userManager.swipesCount)",   label: "Свайпов", color: .purple)
                    }
                    .padding(.horizontal, 15)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("любимые жанры")
                                .foregroundColor(.gray)
                                .font(.system(size: 15, weight: .bold))
                                .textCase(.uppercase)
                            Spacer()
                            Button { showGenreEdit = true } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "pencil").font(.system(size: 13))
                                    Text("Изменить").font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.myRed)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.myPink)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.myRed.opacity(0.3), lineWidth: 1))
                            }
                        }

                        if userManager.selectedGenres.isEmpty {
                            Button { showGenreEdit = true } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Добавить жанры")
                                }
                                .foregroundColor(.myRed.opacity(0.6))
                                .font(.subheadline)
                            }
                        } else {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 10
                            ) {
                                ForEach(userManager.selectedGenres, id: \.self) { genre in
                                    Text(genre)
                                        .foregroundColor(.myRed)
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .background(Color.myPink)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.myRed.opacity(0.2), lineWidth: 2))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)

                    Button {
                        try? Auth.auth().signOut()
                        currentScreen = .login
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Выйти из аккаунта")
                        }
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { userManager.loadUser() }
        .sheet(isPresented: $showSettings, onDismiss: {
            userManager.loadUser()
        }) {
            SettingsView(userManager: userManager, currentScreen: $currentScreen)
        }
        .sheet(isPresented: $showGenreEdit, onDismiss: {
            userManager.loadUser()
        }) {
            GenreEditView(userManager: userManager)
        }
    }

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .foregroundColor(color)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .foregroundColor(color.opacity(0.8))
                .font(.system(size: 14, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(color.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 2))
        .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    ProfileView(currentScreen: .constant(.mainTab))
}
