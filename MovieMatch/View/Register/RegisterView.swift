//
//  RegisterView.swift
//  MovieMatch
//
//  Created by Ilya on 13.04.2026.
//

import SwiftUI

struct RegisterView: View {

    @StateObject private var authManager = AuthManager()
    @Binding var currentScreen: AppScreen
    @State private var login = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: Field?

    enum Field { case login, email, password }

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()
                .onTapGesture { focusedField = nil }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {

                    Text("Создать аккаунт")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.myRed)
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                    Text("login")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.gray)
                        .textCase(.uppercase)

                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.myRed)
                        TextField("Введите Логин", text: $login)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .login)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }
                    }
                    .padding(.horizontal, 15)
                    .frame(width: 350, height: 55)
                    .background(Color.myPersik)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(focusedField == .login ? Color.myRed : Color.myRed.opacity(0.5), lineWidth: 2))

                    Text("email")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                        .padding(.top, 4)

                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.myRed)
                        TextField("mail@mail.ru", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                    }
                    .padding(.horizontal, 15)
                    .frame(width: 350, height: 55)
                    .background(Color.myPersik)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(focusedField == .email ? Color.myRed : Color.myRed.opacity(0.5), lineWidth: 2))

                    Text("пароль")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                        .padding(.top, 4)

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.myRed)

                        ZStack {
                            TextField("*******", text: $password)
                                .autocapitalization(.none)
                                .opacity(isPasswordVisible ? 1 : 0)
                            SecureField("*******", text: $password)
                                .opacity(isPasswordVisible ? 0 : 1)
                        }
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }

                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.myRed)
                                .font(.system(size: 18))
                        }
                    }
                    .padding(.horizontal, 15)
                    .frame(width: 350, height: 55)
                    .background(Color.myPersik)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(focusedField == .password ? Color.myRed : Color.myRed.opacity(0.5), lineWidth: 2))

                    Spacer().frame(height: 30)

                    Button {
                        focusedField = nil
                        authManager.registerUser(email: email, password: password, username: login)
                    } label: {
                        Text("Зарегистироваться")
                            .foregroundColor(.white)
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 350, height: 65)
                            .background(LinearGradient(
                                colors: [Color.myRed, Color.pink],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(25)
                    }

                    HStack {
                        Text("Уже есть аккаунт?")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.gray)

                        Button {
                            currentScreen = .login
                        } label: {
                            Text("Войти")
                                .foregroundColor(.myRed)
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                        }
                    }
                    .frame(width: 350)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: authManager.isAuthenticated) { _, newValue in
            if newValue { currentScreen = .genreSelection }
        }
    }
}

#Preview {
    RegisterView(currentScreen: .constant(.register))
}
