//
//  PartnerConnectorView.swift
//  MovieMatch
//
//  Created by Ilya on 28.05.2026.
//

import SwiftUI

struct PartnerConnectorView: View {
    @Binding var isHeartBeating: Bool
    var userManager: UserManager
    var partnerName: String?
    var partnerAvatarBase64: String?

    var partnerInitials: String {
        guard let name = partnerName, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ").map { String($0.prefix(1)).uppercased() }
        return parts.count >= 2 ? parts[0] + parts[1] : String(name.prefix(2)).uppercased()
    }

    var partnerImage: UIImage? {
        guard let b64 = partnerAvatarBase64, !b64.isEmpty,
              let data = Data(base64Encoded: b64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        HStack(spacing: 15) {

            VStack(spacing: 6) {
                AvatarView(userManager: userManager, size: 75)
                Text("Вы")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 8) {
                Text("• • •")
                    .foregroundColor(partnerName != nil ? .myRed : .myRed.opacity(0.4))
                    .font(.headline)
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(.myRed)
                    .scaleEffect(isHeartBeating ? 1.2 : 0.95)
                Text("• • •")
                    .foregroundColor(partnerName != nil ? .myRed : .myRed.opacity(0.4))
                    .font(.headline)
            }

            VStack(spacing: 6) {
                ZStack {
                    if let img = partnerImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.myRed, lineWidth: 2))
                            .shadow(color: Color.myRed.opacity(0.15), radius: 5, x: 0, y: 3)
                    } else {
                        Circle()
                            .fill(partnerName != nil ? Color.white : Color.myPink)
                            .frame(width: 75, height: 75)
                            .overlay(
                                Circle()
                                    .stroke(
                                        style: partnerName != nil
                                            ? StrokeStyle(lineWidth: 2)
                                            : StrokeStyle(lineWidth: 2, dash: [4])
                                    )
                                    .foregroundColor(partnerName != nil ? .myRed : .gray.opacity(0.5))
                            )
                            .overlay(
                                Text(partnerInitials)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(partnerName != nil ? .myRed : .gray.opacity(0.5))
                            )
                            .shadow(color: partnerName != nil ? Color.myRed.opacity(0.15) : .clear,
                                    radius: 5, x: 0, y: 3)
                    }
                }

                Text(partnerName ?? "Половинка")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
    }
}
