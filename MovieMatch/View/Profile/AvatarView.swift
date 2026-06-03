//
//  AvatarView.swift
//  MovieMatch
//
//  Created by Ilya on 30.05.2026.
//

import SwiftUI

struct AvatarView: View {
    @ObservedObject var userManager: UserManager
    var size: CGFloat = 100
    var showEditButton: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let img = userManager.avatarImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [Color.pink, Color.myRed],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Text(userManager.initials.isEmpty ? "?" : userManager.initials)
                            .font(.system(size: size * 0.32, weight: .bold))
                            .foregroundColor(.white)
                    )
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .shadow(color: Color.myRed.opacity(0.3), radius: 8, x: 0, y: 4)

            if showEditButton {
                Image(systemName: "camera.fill")
                    .font(.system(size: size * 0.13))
                    .foregroundColor(.white)
                    .frame(width: size * 0.3, height: size * 0.3)
                    .background(Color.myRed)
                    .clipShape(Circle())
                    .shadow(color: Color.myRed.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(x: 4, y: 4)
                    .allowsHitTesting(false) 
            }
        }
    }
}
