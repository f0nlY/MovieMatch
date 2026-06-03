//
//  SessionStartView.swift
//  MovieMatch
//
//  Created by Ilya on 27.05.2026.
//

import SwiftUI

struct SessionStartView: View {
    @Binding var selectedTab: Int
    @ObservedObject var viewModel: SessionViewModel
    @StateObject private var userManager = UserManager()
    @StateObject private var networkManager = NetworkManager()

    var body: some View {
        ZStack {
            Color.myPinkBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {

                    VStack(spacing: 8) {
                        Text("Комната сессии")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.myRed)

                        Text("Подключитесь к одной сессии со своей половинкой и найдите мэтч")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .padding(.top, 25)

                    PartnerConnectorView(
                        isHeartBeating: $viewModel.isHeartBeating,
                        userManager: userManager,
                        partnerName: viewModel.partnerName,
                        partnerAvatarBase64: viewModel.partnerAvatarBase64
                    )
                    .padding(.top, 10)

                    ZStack {
                        mainSelectionButtons
                            .opacity(!viewModel.showGeneratedCode && !viewModel.showInputCode ? 1 : 0)
                            .scaleEffect(!viewModel.showGeneratedCode && !viewModel.showInputCode ? 1 : 0.92)

                        waitingForPartnerView
                            .opacity(viewModel.showGeneratedCode ? 1 : 0)
                            .scaleEffect(viewModel.showGeneratedCode ? 1 : 0.92)

                        enterCodeView
                            .opacity(viewModel.showInputCode ? 1 : 0)
                            .scaleEffect(viewModel.showInputCode ? 1 : 0.92)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showGeneratedCode)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showInputCode)

                    if !viewModel.showGeneratedCode && !viewModel.showInputCode {
                        TrendingMovies(networkManager: networkManager)
                            .padding(.bottom, 20)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.showGeneratedCode)
                .animation(.easeInOut(duration: 0.3), value: viewModel.showInputCode)
            }
            
            if viewModel.sessionStatus == "negotiating" {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }
                
                SessionSettingsView(viewModel: viewModel)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { hideKeyboard() }
        .onChange(of: viewModel.isSessionActive) { _, newValue in
            if newValue {
                userManager.incrementSessions()
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    selectedTab = 1
                }
            }
        }
        .onAppear {
            userManager.loadUser()
            networkManager.fetchPopularMovies()
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.sessionStatus)
    }

    private var mainSelectionButtons: some View {
        VStack(spacing: 15) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.generateRoomCode(currentUser: userManager)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Создать сессию")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(width: 320, height: 55)
                .background(
                    LinearGradient(colors: [Color.pink, Color.myRed], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(20)
                .shadow(color: Color.myRed.opacity(0.3), radius: 8, x: 0, y: 4)
            }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.showInputCode = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "key.fill")
                        .font(.title3)
                    Text("Войти по коду")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .foregroundColor(.myRed)
                .frame(width: 320, height: 55)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.myRed, lineWidth: 2)
                )
            }
        }
        .padding()
        .background(Color.myPink.opacity(0.5))
        .cornerRadius(25)
        .padding(.horizontal, 25)
    }

    private var waitingForPartnerView: some View {
        VStack(spacing: 20) {
            Text("Код твоей комнаты:")
                .font(.headline)
                .foregroundColor(.gray)

            Text(viewModel.generatedCode)
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.myRed)
                .tracking(4)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.myRed.opacity(0.3), lineWidth: 1.5))
                .shadow(color: Color.myRed.opacity(0.1), radius: 6, x: 0, y: 3)

            HStack(spacing: 8) {
                ProgressView()
                    .tint(.myRed)
                Text(viewModel.isConnected ? "Подключение установлено!" : "Ожидаем половинку...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .italic()
            }

            Button {
                let code = viewModel.generatedCode
                let av = UIActivityViewController(activityItems: ["Привет! Вот мой код для MovieMatch: \(code)"], applicationActivities: nil)
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let vc = scene.windows.first?.rootViewController {
                    vc.present(av, animated: true)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Поделиться кодом")
                }
                .foregroundColor(.myRed)
                .font(.system(size: 15, weight: .semibold))
            }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.cancelSession()
                }
            } label: {
                Text("Отмена")
                    .foregroundColor(.gray)
                    .font(.system(size: 15, weight: .medium))
            }
        }
        .padding(20)
        .background(Color.myPink.opacity(0.5))
        .cornerRadius(25)
        .padding(.horizontal, 25)
    }
    
    private var enterCodeView: some View {
        VStack(spacing: 20) {
            Text("Введите код партнера")
                .font(.headline)
                .foregroundColor(.gray)

            TextField("000 000", text: $viewModel.sessionCodeInput)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .foregroundColor(.myRed)
                .frame(width: 320, height: 60)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.myRed, lineWidth: 2))
                .onChange(of: viewModel.sessionCodeInput) { newValue in
                    let numbers = newValue.filter { $0.isNumber }
                    let limited = String(numbers.prefix(6))
                    var formatted = ""
                    
                    for (index, char) in limited.enumerated() {
                        if index == 3 {
                            formatted.append(" ")
                        }
                        formatted.append(char)
                    }
                    
                    if newValue != formatted {
                        viewModel.sessionCodeInput = formatted
                    }
                }

            Button {
                viewModel.connectToRoom(currentUser: userManager)
            } label: {
                Text("Подключиться")
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 320, height: 55)
                    .background(
                        LinearGradient(
                            colors: viewModel.sessionCodeInput.filter { $0.isNumber }.count < 6
                                ? [Color.gray.opacity(0.4)]
                                : [Color.pink, Color.myRed],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(
                        color: viewModel.sessionCodeInput.filter { $0.isNumber }.count < 6
                            ? .clear : Color.myRed.opacity(0.3),
                        radius: 8, x: 0, y: 4
                    )
            }
            .disabled(viewModel.sessionCodeInput.filter { $0.isNumber }.count < 6)
            .animation(.easeInOut(duration: 0.2), value: viewModel.sessionCodeInput.count)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.showInputCode = false
                    viewModel.sessionCodeInput = ""
                }
            } label: {
                Text("Назад")
                    .foregroundColor(.gray)
                    .font(.system(size: 15, weight: .medium))
            }
        }
        .padding(20)
        .background(Color.myPink.opacity(0.5))
        .cornerRadius(25)
        .padding(.horizontal, 25)
    }
}
