//
//  AboutFilmView.swift
//  MovieMatch
//
//  Created by Ilya on 20.04.2026.
//

import SwiftUI

struct AboutFilmView: View {
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            VStack{
                VStack{
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.white)
                        .font(.system(size: 150))
                    
                    Spacer()
                    
                    Text("Интерстеллар")
                        .foregroundStyle(.white)
                        .font(.system(size: 30, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.blue)
                HStack{
                    VStack{
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.system(size: 30, weight: .bold))
                        Text("8.6")
                        .foregroundStyle(.white)
                        .frame(maxWidth:.infinity )
                    }
                    Text("2014")
                        .foregroundStyle(.white)
                    Text("2ч 19мин")
                        .foregroundStyle(.white)
                        .frame(maxWidth:.infinity )
                    Text("Sci-\nFi")
                        .foregroundStyle(.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 3))
                        .frame(maxWidth:.infinity, maxHeight: .infinity)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity )
                .background(.red)
                VStack{
                    Text("Команда исследователей путешествует через червоточину в поисках нового дома для человечества...")
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                VStack{
                    Text("Режиссер")
                        .foregroundStyle(.white.opacity(0.7))
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    
                    Text("Кристофер Нолан")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    
                    Text("В РОЛЯХ")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .padding(.leading, 15)
                        .padding(.top, 10)
                    
                    Text("Мэттью МакКонахи, Энн Хэтэуэй, Джессика Честейн")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                }
                HStack{
                    Button{
                        
                    } label: {
                        VStack{
                            ZStack{
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 37))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                                
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 35))
                                    .foregroundStyle(.red)
                            }
                            Text("Лайк")
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: 100, maxHeight: 100)
                        .background(LinearGradient(
                            colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 10))).foregroundStyle(.purple)
                        .clipShape(.rect(cornerRadius: 10))
                    }
                    
                    Button{
                        
                    } label: {
                        Text("X   Нет")
                    }
                    .frame(maxWidth: 100, maxHeight: 100)
                    .background(Color.red)
                }
            }
        }
    }
}

#Preview {
    AboutFilmView()
}
