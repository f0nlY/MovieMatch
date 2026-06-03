//
//  ContentView.swift
//  MovieMatch
//
//  Created by Ilya on 13.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var currentScreen: AppScreen = .loading
    @State private var selectedTab: Int = 0

    var body: some View {
        switch currentScreen {
        case .loading:
            LoadingView(currentScreen: $currentScreen)
        case .login:
            LoginView(currentScreen: $currentScreen)
        case .register:
            RegisterView(currentScreen: $currentScreen)
        case .genreSelection:
            ChooseGenre(currentScreen: $currentScreen)
        case .mainTab:
            MainContainerView(selectedTab: $selectedTab, currentScreen: $currentScreen)
        }
    }
}

struct MainContainerView: View {
    @Binding var selectedTab: Int
    @Binding var currentScreen: AppScreen
    @StateObject private var sessionViewModel = SessionViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case 0:
                    SessionStartView(
                        selectedTab: $selectedTab,
                        viewModel: sessionViewModel
                    )
                case 1:
                    SwipeView(
                        sessionViewModel: sessionViewModel
                    )
                case 2:
                    // 🔥 ТЕПЕРЬ ОТКРЫВАЕТСЯ НАШЕ ОКНО ИСТОРИИ
                    SessionHistoryView()
                case 3:
                    ProfileView(currentScreen: $currentScreen)
                default:
                    SessionStartView(
                        selectedTab: $selectedTab,
                        viewModel: sessionViewModel
                    )
                }
            }

            LowSideBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
