//
//  LowSideBar.swift
//  MovieMatch
//
//  Created by Ilya on 18.04.2026.
//

import SwiftUI

struct LowSideBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.myRed.opacity(0.15))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                tabButton(icon: "house",     label: "Главная",  tag: 0)
                tabButton(icon: "hand.draw", label: "Свайп",    tag: 1)
                tabButton(icon: "book.pages",     label: "История",     tag: 2)
                tabButton(icon: "person",    label: "Профиль",  tag: 3)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial)
    }

    private func tabButton(icon: String, label: String, tag: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tag ? "\(icon).fill" : icon)
                    .font(.system(size: 22))
                    .scaleEffect(selectedTab == tag ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)

                Text(label)
                    .font(.system(size: 11, weight: selectedTab == tag ? .semibold : .regular))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selectedTab == tag ? Color.myRed : Color.gray.opacity(0.7))
        }
    }
}

#Preview {
    LowSideBar(selectedTab: .constant(0))
}
