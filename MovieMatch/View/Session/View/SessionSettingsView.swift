//
//  SessionSettingsView.swift
//  MovieMatch
//
//  Created by Ilya on 31.05.2026.
//

import SwiftUI

struct SessionSettingsView: View {
    @ObservedObject var viewModel: SessionViewModel
    
    let allGenres = Movie.genreDictionary.map { Genre(id: $0.key, name: $0.value) }.sorted(by: { $0.name < $1.name })
    
    var isMeReady: Bool {
        viewModel.isCurrentUserHost ? viewModel.isHostReady : viewModel.isGuestReady
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            VStack(spacing: 8) {
                Text("Ваши общие жанры ✨")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.myRed)
                
                Text("Мы нашли пересечения в ваших вкусах.\nВыбирайте жанры для этой сессии!")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            .padding(.top, 10)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120))], spacing: 10) {
                    ForEach(allGenres) { genre in
                        let isSelected = viewModel.sessionGenres.contains(genre.name)
                        
                        let textColor = isSelected ? Color.white : Color.myRed
                        let bgColor = isSelected ? Color.myRed : Color.myPink
                        let strokeColor = isSelected ? Color.clear : Color.myRed.opacity(0.3)
                        let shadowColor = isSelected ? Color.myRed.opacity(0.3) : Color.clear
                        
                        Button {
                            if !isMeReady {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.toggleSessionGenre(genre.name)
                                }
                            }
                        } label: {
                            Text(genre.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(textColor)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(bgColor)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(strokeColor, lineWidth: 1.5)
                                )
                                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
            }
            .frame(maxHeight: 220)
            
            let btnTextColor = isMeReady ? Color.gray : Color.white
            let btnGradientColors = isMeReady ? [Color.white, Color.white] : [Color.pink, Color.myRed]
            let btnStrokeColor = isMeReady ? Color.gray.opacity(0.3) : Color.clear
            let btnShadowColor = isMeReady ? Color.clear : Color.myRed.opacity(0.3)
            
            Button {
                withAnimation {
                    viewModel.toggleReadyStatus()
                }
            } label: {
                HStack(spacing: 8) {
                    if isMeReady {
                        ProgressView().tint(.gray)
                        Text("Ждём партнера...")
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Всё супер, я готов!")
                    }
                }
                .font(.headline)
                .foregroundColor(btnTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 55)         
                .background(
                    LinearGradient(colors: btnGradientColors, startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(btnStrokeColor, lineWidth: 2)
                )
                .shadow(color: btnShadowColor, radius: 8, x: 0, y: 4)
            }
            .padding(.top, 5)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 10)
        .padding(.horizontal, 25)
    }
}
