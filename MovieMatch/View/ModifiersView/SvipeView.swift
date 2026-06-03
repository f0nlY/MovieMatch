//
//  SvipeView.swift
//  MovieMatch
//
//  Created by Ilya on 23.05.2026.
//

import SwiftUI

struct SvipeView: View {

    var actionLeft: () -> Void
    var actionMiddle: () -> Void
    var actionRight: () -> Void

    var body: some View {
        HStack {

            Button {
                actionLeft()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.red, lineWidth: 6)
                        .frame(maxWidth: 80, maxHeight: 80)
                    ZStack {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 4, height: 35)
                            .rotationEffect(.degrees(45))
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 4, height: 35)
                            .rotationEffect(.degrees(-45))
                    }
                }
                .padding()
            }

            Button {
                actionMiddle()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.yellow, lineWidth: 10)
                        .frame(maxWidth: 80, maxHeight: 80)
                    Image(systemName: "star")
                        .resizable()
                        .foregroundStyle(Color.yellow)
                        .frame(width: 35, height: 35)
                }
                .padding()
            }

            Button {
                actionRight()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.green, lineWidth: 10)
                        .frame(maxWidth: 80, maxHeight: 80)
                    Image(systemName: "heart")
                        .resizable()
                        .foregroundStyle(Color.green)
                        .frame(width: 35, height: 35)
                }
                .padding()
            }
        }
    }
}
