//
//  HistoryOfMatches.swift
//  MovieMatch
//
//  Created by Ilya on 14.05.2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CompletedSession: Identifiable {
    let id: String
    let data: [String: Any]
}

struct SessionHistoryView: View {
    @State private var completedSessions: [CompletedSession] = []
    @State private var isLoading = false
    @State private var selectedSession: CompletedSession? = nil
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.myPinkBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Загрузка истории...")
                        .tint(.myRed)
                        .scaleEffect(1.2)
                } else if completedSessions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 80))
                            .foregroundColor(.myRed.opacity(0.3))
                            .padding(.bottom, 10)
                        
                        Text("История сессий пуста")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(.myRed)
                        
                        Text("Свайпайте фильмы в паре со своей половинкой, завершайте сессии, и ваши результаты будут бережно храниться здесь!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .lineSpacing(4)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            ForEach(completedSessions) { session in
                                sessionCard(session: session)
                                    .onTapGesture {
                                        selectedSession = session
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                        .padding(.bottom, 110)
                    }
                }
            }
            .navigationTitle("История сессий")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadCompletedSessions()
            }
            .sheet(item: $selectedSession) { session in
                SessionHistoryDetailView(session: session)
            }
        }
    }
    
    private func sessionCard(session: CompletedSession) -> some View {
        let data = session.data
        let currentUid = Auth.auth().currentUser?.uid ?? ""
        
        let hostId = data["hostId"] as? String ?? ""
        let isHost = currentUid == hostId
        
        let partnerName = isHost ? (data["guestName"] as? String ?? "Половинка") : (data["hostName"] as? String ?? "Создатель")
        let partnerAvatar = isHost ? (data["guestAvatar"] as? String ?? "") : (data["hostAvatar"] as? String ?? "")
        
        let endedAt = data["endedAt"] as? Timestamp ?? Timestamp(date: Date())
        
        let hostLikes = data["hostLikes"] as? [Int] ?? []
        let guestLikes = data["guestLikes"] as? [Int] ?? []
        let matchesCount = Set(hostLikes).intersection(Set(guestLikes)).count
        
        return HStack(spacing: 15) {
            if !partnerAvatar.isEmpty, let imgData = Data(base64Encoded: partnerAvatar), let uiImg = UIImage(data: imgData) {
                Image(uiImage: uiImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.myRed, lineWidth: 1.5))
            } else {
                Circle()
                    .fill(Color.myRed.opacity(0.1))
                    .frame(width: 55, height: 55)
                    .overlay(
                        Text(String(partnerName.prefix(2)).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.myRed)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Сессия с \(partnerName)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.myRed)
                
                Text(formatDate(endedAt))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("\(matchesCount)")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.myRed)
                Text("Мэтчей")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.myRed.opacity(0.08))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private func loadCompletedSessions() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        db.collection("completed_sessions")
            .whereField("hostId", isEqualTo: uid)
            .getDocuments { hostSnapshot, _ in
                
                self.db.collection("completed_sessions")
                    .whereField("guestId", isEqualTo: uid)
                    .getDocuments { guestSnapshot, _ in
                        
                        var loaded: [CompletedSession] = []
                        
                        if let docs = hostSnapshot?.documents {
                            for doc in docs {
                                loaded.append(CompletedSession(id: doc.documentID, data: doc.data()))
                            }
                        }
                        
                        if let docs = guestSnapshot?.documents {
                            for doc in docs {
                                loaded.append(CompletedSession(id: doc.documentID, data: doc.data()))
                            }
                        }
                        
                        loaded.sort { a, b in
                            let timeA = a.data["endedAt"] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: 0))
                            let timeB = b.data["endedAt"] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: 0))
                            return timeA.dateValue() > timeB.dateValue()
                        }
                        
                        DispatchQueue.main.async {
                            self.completedSessions = loaded
                            self.isLoading = false
                        }
                    }
            }
    }
    
    private func formatDate(_ timestamp: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: timestamp.dateValue())
    }
}
