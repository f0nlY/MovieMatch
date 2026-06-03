//
//  LoadingView.swift
//  MovieMatch
//
//  Created by Ilya on 14.04.2026.
//

import SwiftUI

struct LoadingView: View {
    @Binding var currentScreen: AppScreen
    var body: some View {
        NavigationStack{
            ZStack{
                Color.myPinkBackground.ignoresSafeArea()
                VStack{
                    Image("iconImage")
                        .resizable()
                        .frame(maxWidth: 200, maxHeight: 200)
                    Text("MovieMatch")
                        .foregroundStyle(Color.myRed)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(3)
                    Text("Тиндер для фильмов для вас двоих")
                        .foregroundStyle(Color.gray.opacity(0.7))
                        .frame(maxWidth: 170)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 75)
                    NavigationLink{
                        RegisterView(currentScreen: $currentScreen)
                    } label: {
                        Text("Создать аккаунт")
                            .foregroundStyle(Color.white)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: 275, maxHeight: 85)
                    .background(LinearGradient(
                        colors: [Color.pink, Color.purple], startPoint: .leading, endPoint: .trailing
                    ))
                    .cornerRadius(50)
                    .padding(8)
                    
                    NavigationLink{
                        LoginView(currentScreen: $currentScreen)
                    } label:{
                        Text("Войти")
                            .foregroundStyle(Color.white.opacity(0.7))
                            .font(.title)
                    }
                    .frame(maxWidth: 275, maxHeight: 85)
                    .background(Color.black)
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.gray.opacity(0.5), lineWidth: 3))
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    LoadingView(currentScreen: .constant(.loading))
}
