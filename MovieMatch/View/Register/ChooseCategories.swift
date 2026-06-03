//
//  ChooseCategories.swift
//  MovieMatch
//
//  Created by Ilya on 27.05.2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChooseGenre: View {
    @Binding var currentScreen: AppScreen
    @State private var selectedGenres: Set<Int> = []

    let genresList = [
        Genre(id: 28,    name: "Боевик"),
        Genre(id: 12,    name: "Приключения"),
        Genre(id: 16,    name: "Мультфильм"),
        Genre(id: 35,    name: "Комедия"),
        Genre(id: 80,    name: "Криминал"),
        Genre(id: 99,    name: "Документальный"),
        Genre(id: 18,    name: "Драма"),
        Genre(id: 10751, name: "Семейный"),
        Genre(id: 14,    name: "Фэнтези"),
        Genre(id: 36,    name: "История"),
        Genre(id: 27,    name: "Ужасы"),
        Genre(id: 10402, name: "Музыка"),
        Genre(id: 9648,  name: "Детектив"),
        Genre(id: 10749, name: "Мелодрама"),
        Genre(id: 878,   name: "Фантастика"),
        Genre(id: 10770, name: "ТВ-Фильм"),
        Genre(id: 53,    name: "Триллер"),
        Genre(id: 10752, name: "Военный"),
        Genre(id: 37,    name: "Вестерн")
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Выбирай")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundStyle(Color.myRed)

                    Text("Несколько жанров и мы подберём для вас фильм")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 25)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(genresList) { genre in
                            let isSelected = selectedGenres.contains(genre.id)
                            Button {
                                if isSelected { selectedGenres.remove(genre.id) }
                                else          { selectedGenres.insert(genre.id) }
                            } label: {
                                Text(genre.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(isSelected ? .myPink : .myRed)
                                    .frame(maxWidth: .infinity, minHeight: 55)
                                    .background(isSelected ? Color.myRed : Color.myPink)
                                    .cornerRadius(15)
                                    .shadow(color: isSelected ? Color.myRed.opacity(0.3) : Color.black.opacity(0.1),
                                            radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                }

                Button {
                    saveGenresAndContinue()
                } label: {
                    Text("Продолжить")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: 280, minHeight: 55)
                        .background(
                            LinearGradient(
                                colors: selectedGenres.isEmpty
                                    ? [Color.gray.opacity(0.5)]
                                    : [Color.pink, Color.myRed],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: selectedGenres.isEmpty ? .clear : Color.myRed.opacity(0.25),
                                radius: 8, x: 0, y: 4)
                }
                .disabled(selectedGenres.isEmpty)
                .padding(.bottom, 20)
            }
        }
    }

    private func saveGenresAndContinue() {
        guard let uid = Auth.auth().currentUser?.uid else {
            currentScreen = .mainTab
            return
        }

        let names = genresList
            .filter { selectedGenres.contains($0.id) }
            .map { $0.name }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData(["genres": names]) { _ in
                DispatchQueue.main.async {
                    currentScreen = .mainTab
                }
            }
    }
}

#Preview {
    ChooseGenre(currentScreen: .constant(.genreSelection))
}
