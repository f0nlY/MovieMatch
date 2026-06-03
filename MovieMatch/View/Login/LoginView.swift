//
//  LoginView.swift
//  MovieMatch
//
//  Created by Ilya on 17.04.2026.
//

import SwiftUI

struct LoginView: View {
    @Binding var currentScreen: AppScreen
    @StateObject private var authManager = AuthManager()
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()
                .onTapGesture { focusedField = nil }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    VStack(spacing: 8) {
                        Image("iconImage")
                            .resizable()
                            .frame(width: 160, height: 160)
                            .padding(.top, 40)

                        Text("С возвращением!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.myRed)
                    }

                    Spacer()
                        .frame(height: 45)

                    VStack(spacing: 14) {

                        HStack {
                            Image(systemName: "envelope")
                                .foregroundStyle(Color.pink)
                            TextField("mail@mail.ru", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }
                        }
                        .padding()
                        .background(Color.myPink)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(focusedField == .email ? Color.myRed : Color.myRed.opacity(0.4), lineWidth: 4))
                        .frame(width: 350, height: 55)
                        .clipShape(.rect(cornerRadius: 10))

                        HStack {
                            Image(systemName: "lock")
                                .foregroundStyle(Color.pink)

                            ZStack {
                                TextField("Пароль", text: $password)
                                    .autocapitalization(.none)
                                    .opacity(isPasswordVisible ? 1 : 0)
                                SecureField("Пароль", text: $password)
                                    .opacity(isPasswordVisible ? 0 : 1)
                            }
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.pink)
                                    .font(.system(size: 18))
                            }
                        }
                        .padding()
                        .background(Color.myPink)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(focusedField == .password ? Color.myRed : Color.myRed.opacity(0.4), lineWidth: 4))
                        .frame(width: 350, height: 55)
                        .clipShape(.rect(cornerRadius: 10))

                        Button { } label: {
                            Text("Забыл пароль?")
                                .foregroundStyle(Color.myRed)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(width: 350, alignment: .trailing)
                    }

                    Spacer()
                        .frame(height: 45)

                    VStack(spacing: 16) {
                        Button {
                            focusedField = nil
                            authManager.loginUser(email: email, password: password)
                        } label: {
                            Text("Войти")
                                .foregroundColor(.white)
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: 300, height: 65)
                                .background(LinearGradient(
                                    colors: [Color.pink, Color.myRed],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .cornerRadius(50)
                        }

                        HStack(spacing: 4) {
                            Text("Нет аккаунта?")
                                .foregroundStyle(Color.gray.opacity(0.7))
                                .font(.system(size: 17, weight: .medium))

                            Button {
                                currentScreen = .register
                            } label: {
                                Text("Создать")
                                    .foregroundStyle(Color.myRed)
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture{
            hideKeyboard()
        }
        .onChange(of: authManager.isAuthenticated) { _, newValue in
            if newValue { currentScreen = .mainTab }
        }
    }
}

#Preview {
    LoginView(currentScreen: .constant(.login))
}
