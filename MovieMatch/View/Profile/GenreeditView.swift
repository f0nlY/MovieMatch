//
//  GenreeditView.swift
//  MovieMatch
//
//  Created by Ilya on 30.05.2026.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GenreEditView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedGenres: Set<String> = []
    @State private var isSaving = false

    let allGenres = [
        "Боевик", "Приключения", "Мультфильм", "Комедия",
        "Криминал", "Документальный", "Драма", "Семейный",
        "Фэнтези", "История", "Ужасы", "Музыка",
        "Детектив", "Мелодрама", "Фантастика", "ТВ-Фильм",
        "Триллер", "Военный", "Вестерн"
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.myRed)
                            .frame(width: 36, height: 36)
                            .background(Color.myPink)
                            .clipShape(Circle())
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Мои жанры")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.myRed)
                        Text("Выбрано: \(selectedGenres.count)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Text("Нажми на жанр чтобы добавить или убрать")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(allGenres, id: \.self) { genre in
                            let isSelected = selectedGenres.contains(genre)

                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if isSelected {
                                        selectedGenres.remove(genre)
                                    } else {
                                        selectedGenres.insert(genre)
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    Text(genre)
                                        .font(.system(size: 15, weight: .semibold))
                                        .lineLimit(1)
                                }
                                .foregroundColor(isSelected ? .white : .myRed)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(
                                    isSelected
                                        ? LinearGradient(colors: [Color.pink, Color.myRed],
                                                         startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.myPink, Color.myPink],
                                                         startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(14)
                                .shadow(
                                    color: isSelected ? Color.myRed.opacity(0.3) : Color.clear,
                                    radius: 4, x: 0, y: 2
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            isSelected ? Color.clear : Color.myRed.opacity(0.2),
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .scaleEffect(isSelected ? 1.02 : 1.0)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }

                Button {
                    saveGenres()
                } label: {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Сохранить")
                        }
                    }
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: 56)
                    .background(
                        selectedGenres.isEmpty
                            ? LinearGradient(colors: [Color.gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.pink, Color.myRed], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(20)
                    .shadow(
                        color: selectedGenres.isEmpty ? .clear : Color.myRed.opacity(0.3),
                        radius: 8, x: 0, y: 4
                    )
                }
                .disabled(selectedGenres.isEmpty || isSaving)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .animation(.easeInOut(duration: 0.2), value: selectedGenres.isEmpty)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture{
            hideKeyboard()
        }
        .onAppear {
            selectedGenres = Set(userManager.selectedGenres)
        }
    }

    private func saveGenres() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSaving = true

        let genresArray = Array(selectedGenres).sorted()

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData(["genres": genresArray]) { error in
                DispatchQueue.main.async {
                    isSaving = false
                    if error == nil {
                        userManager.selectedGenres = genresArray
                        dismiss()
                    }
                }
            }
    }
}

#Preview {
    GenreEditView(userManager: UserManager())
}
