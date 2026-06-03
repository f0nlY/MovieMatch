//
//  SettingsView.swift
//  MovieMatch
//
//  Created by Ilya on 30.05.2026.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @ObservedObject var userManager: UserManager
    @Binding var currentScreen: AppScreen
    @Environment(\.dismiss) var dismiss
    @State private var newUsername: String = ""
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var showChangePassword = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isUploadingAvatar = false
    @State private var imageForCrop: UIImage? = nil
    @State private var showCropView = false

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()
                .onTapGesture { hideKeyboard() }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.myRed)
                                .frame(width: 36, height: 36)
                                .background(Color.myPink)
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("Настройки")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.myRed)
                        Spacer()
                        Button { saveUsername() } label: {
                            Text(isSaving ? "..." : "Сохранить")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSaving ? Color.gray.opacity(0.4) : Color.myRed)
                                .cornerRadius(10)
                        }
                        .disabled(isSaving)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    ZStack {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            AvatarView(
                                userManager: userManager,
                                size: 100,
                                showEditButton: true
                            )
                        }
                        .buttonStyle(.plain)

                        if isUploadingAvatar {
                            Circle()
                                .fill(Color.black.opacity(0.45))
                                .frame(width: 100, height: 100)
                                .overlay(ProgressView().tint(.white))
                        }
                    }
                    .padding(.bottom, 8)

                    Text("Нажми на фото чтобы изменить")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.bottom, 24)

                    sectionHeader("Профиль")

                    settingsRow(icon: "person.fill", iconColor: .myRed) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Имя пользователя")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField(userManager.username, text: $newUsername)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.myRed)
                                .autocapitalization(.none)
                        }
                    }

                    settingsRow(icon: "envelope.fill", iconColor: .orange) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Text(userManager.email)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                    }

                    if showSuccess {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Сохранено!")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }

                    sectionHeader("Аккаунт")
                        .padding(.top, 20)

                    Button { showChangePassword = true } label: {
                        settingsRow(icon: "lock.fill", iconColor: .blue) {
                            HStack {
                                Text("Сменить пароль")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .font(.system(size: 14))
                            }
                        }
                    }

                    settingsRow(icon: "info.circle.fill", iconColor: .teal) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Версия приложения")
                                .font(.system(size: 16, weight: .medium))
                            Text("MovieMatch 1.0.0")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }

                    Button {
                        try? Auth.auth().signOut()
                        dismiss()
                        currentScreen = .login
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Выйти из аккаунта")
                        }
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, maxHeight: 52)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1.5))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { newUsername = userManager.username }
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        imageForCrop = image
                        showCropView = true
                        selectedItem = nil
                    }
                }
            }
        }

        .fullScreenCover(isPresented: $showCropView) {
            if let img = imageForCrop {
                ImageCropView(
                    image: img,
                    onCrop: { croppedImage in
                        showCropView = false
                        imageForCrop = nil
                        isUploadingAvatar = true
                        userManager.saveAvatar(croppedImage) { _ in
                            isUploadingAvatar = false
                        }
                    },
                    onCancel: {
                        showCropView = false
                        imageForCrop = nil
                    }
                )
            }
        }

        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
    }

    private func saveUsername() {
        guard let uid = Auth.auth().currentUser?.uid,
              !newUsername.isEmpty else { return }
        isSaving = true
        Firestore.firestore().collection("users").document(uid)
            .updateData(["username": newUsername]) { error in
                DispatchQueue.main.async {
                    isSaving = false
                    if error == nil {
                        userManager.username = newUsername
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showSuccess = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { showSuccess = false }
                        }
                    }
                }
            }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .tracking(0.5)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    private func settingsRow<Content: View>(
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(iconColor)
                .cornerRadius(8)
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.myPink)
        .cornerRadius(14)
        .padding(.horizontal, 20)
        .padding(.bottom, 2)
    }
}
