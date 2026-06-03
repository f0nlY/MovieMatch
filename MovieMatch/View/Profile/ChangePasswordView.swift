//
//  ChangePasswordView.swift
//  MovieMatch
//
//  Created by Ilya on 30.05.2026.
//

import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showCurrent = false
    @State private var showNew = false
    @State private var showConfirm = false
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @FocusState private var focused: Field?
    
    enum Field { case current, new, confirm }

    var passwordsMatch: Bool { newPassword == confirmPassword }
    var newPasswordValid: Bool { newPassword.count >= 6 }
    var canSave: Bool {
        !currentPassword.isEmpty && newPasswordValid && passwordsMatch && !isSaving
    }

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()
                .onTapGesture { focused = nil }

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
                    Text("Смена пароля")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.myRed)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)

                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.pink, Color.myRed],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.white)
                }
                .shadow(color: Color.myRed.opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.bottom, 30)

                VStack(spacing: 14) {

                    passwordField(
                        label: "Текущий пароль",
                        text: $currentPassword,
                        show: $showCurrent,
                        field: .current,
                        next: .new
                    )

                    passwordField(
                        label: "Новый пароль (мин. 6 символов)",
                        text: $newPassword,
                        show: $showNew,
                        field: .new,
                        next: .confirm
                    )
                    
                    passwordField(
                        label: "Повтори новый пароль",
                        text: $confirmPassword,
                        show: $showConfirm,
                        field: .confirm,
                        next: nil
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        validationRow(
                            ok: newPasswordValid,
                            text: "Минимум 6 символов"
                        )
                        if !confirmPassword.isEmpty {
                            validationRow(
                                ok: passwordsMatch,
                                text: passwordsMatch ? "Пароли совпадают" : "Пароли не совпадают"
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .animation(.easeInOut(duration: 0.2), value: newPassword)
                    .animation(.easeInOut(duration: 0.2), value: confirmPassword)

                    if !errorMessage.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(errorMessage)
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(10)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    if showSuccess {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Пароль успешно изменён!")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    focused = nil
                    changePassword()
                } label: {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "lock.rotation")
                            Text("Изменить пароль")
                        }
                    }
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: 56)
                    .background(
                        canSave
                            ? LinearGradient(colors: [Color.pink, Color.myRed],
                                             startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.4)],
                                             startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(20)
                    .shadow(color: canSave ? Color.myRed.opacity(0.3) : .clear,
                            radius: 8, x: 0, y: 4)
                }
                .disabled(!canSave)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .animation(.easeInOut(duration: 0.2), value: canSave)
            }
        }
    }

    private func passwordField(
        label: String,
        text: Binding<String>,
        show: Binding<Bool>,
        field: Field,
        next: Field?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)

            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.pink)
                    .frame(width: 20)

                ZStack {
                    TextField("", text: text)
                        .autocapitalization(.none)
                        .opacity(show.wrappedValue ? 1 : 0)
                    SecureField("", text: text)
                        .opacity(show.wrappedValue ? 0 : 1)
                }
                .focused($focused, equals: field)
                .submitLabel(next != nil ? .next : .done)
                .onSubmit {
                    if let next { focused = next }
                    else { focused = nil }
                }

                Button {
                    show.wrappedValue.toggle()
                } label: {
                    Image(systemName: show.wrappedValue ? "eye" : "eye.slash")
                        .foregroundColor(.pink)
                        .font(.system(size: 17))
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, maxHeight: 52)
            .background(Color.myPink)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused == field ? Color.myRed : Color.myRed.opacity(0.3), lineWidth: 2)
            )
        }
    }

    private func validationRow(ok: Bool, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: ok ? "checkmark.circle.fill" : "circle")
                .foregroundColor(ok ? .green : .gray.opacity(0.5))
                .font(.system(size: 13))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(ok ? .green : .gray)
        }
    }

    private func changePassword() {
        guard let user = Auth.auth().currentUser,
              let email = user.email else { return }

        isSaving = true
        errorMessage = ""

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error {
                DispatchQueue.main.async {
                    isSaving = false
                    errorMessage = "Неверный текущий пароль"
                    print(error.localizedDescription)
                }
                return
            }

            user.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    isSaving = false
                    if let error {
                        errorMessage = error.localizedDescription
                    } else {
                        withAnimation { showSuccess = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ChangePasswordView()
}
