//
//  SessionViewModel.swift
//  MovieMatch
//
//  Created by Ilya on 28.05.2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class SessionViewModel: ObservableObject {
    @Published var sessionCodeInput: String = ""
    @Published var generatedCode: String = ""
    @Published var activeSessionCode: String = ""
    
    @Published var showGeneratedCode = false
    @Published var showInputCode = false
    @Published var isHeartBeating = false
    @Published var partnerName: String? = nil
    @Published var partnerAvatarBase64: String? = nil
    @Published var isConnected: Bool = false
    @Published var isSessionActive: Bool = false
    
    @Published var showPartnerLeftAlert = false
    @Published var newlyMatchedMovieId: Int? = nil
    private var localDisplayedMatches: Set<Int> = []
    
    // МАССИВ ДЛЯ ПОСЛЕДНИХ 5 ДЕЙСТВИЙ (Отображается в UI)
    @Published var partnerRecentActions: [String] = []
    private var myRecentActions: [String] = []
    
    // состояния сессии
    @Published var sessionStatus: String = "none"
    @Published var sessionGenres: Set<String> = []
    @Published var isCurrentUserHost: Bool = false
    @Published var isHostReady: Bool = false
    @Published var isGuestReady: Bool = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    var currentSessionCode: String {
        let code = isCurrentUserHost ? generatedCode : sessionCodeInput
        return code.replacingOccurrences(of: " ", with: "")
    }

    func generateRoomCode(currentUser: UserManager) {
        let code = String(format: "%06d", Int.random(in: 100000...999999))
        let displayCode = "\(code.prefix(3)) \(code.suffix(3))"

        guard let uid = Auth.auth().currentUser?.uid else { return }

        let sessionData: [String: Any] = [
            "hostId": uid,
            "hostName": currentUser.username,
            "hostAvatar": currentUser.avatarBase64,
            "hostGenres": currentUser.selectedGenres,
            "guestId": "",
            "guestName": "",
            "guestAvatar": "",
            "guestGenres": [],
            "status": "waiting",
            "genres": [],
            "hostReady": false,
            "guestReady": false,
            "hostLikes": [],
            "guestLikes": [],
            "hostDislikes": [],
            "guestDislikes": [],
            "hostFavorites": [],
            "guestFavorites": [],
            "moviesMetadata": [:],
            "hostRecentActions": [],
            "guestRecentActions": []
        ]

        db.collection("sessions").document(code).setData(sessionData) { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        self?.isCurrentUserHost = true
                        self?.activeSessionCode = code
                        self?.sessionStatus = "waiting"
                        self?.generatedCode = displayCode
                        self?.showGeneratedCode = true
                    }
                    self?.listenToSession(code: code, isHost: true)
                }
            }
        }
    }

    func connectToRoom(currentUser: UserManager) {
        let code = sessionCodeInput.replacingOccurrences(of: " ", with: "")
        guard code.count == 6, let uid = Auth.auth().currentUser?.uid else { return }

        let sessionRef = db.collection("sessions").document(code)

        sessionRef.getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(),
                  data["status"] as? String == "waiting" else {
                return
            }

            sessionRef.updateData([
                "guestId": uid,
                "guestName": currentUser.username,
                "guestAvatar": currentUser.avatarBase64,
                "guestGenres": currentUser.selectedGenres,
                "status": "negotiating"
            ]) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self?.isCurrentUserHost = false
                        self?.activeSessionCode = code
                        self?.listenToSession(code: code, isHost: false)
                    }
                }
            }
        }
    }

    private func listenToSession(code: String, isHost: Bool) {
        listener?.remove()

        listener = db.collection("sessions").document(code)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                    if self.isConnected || self.isSessionActive {
                        self.handlePartnerLeft()
                    }
                    return
                }

                let status = data["status"] as? String ?? ""
                let hReady = data["hostReady"] as? Bool ?? false
                let gReady = data["guestReady"] as? Bool ?? false
                let fetchedGenres = data["genres"] as? [String] ?? []
                let hostG = data["hostGenres"] as? [String] ?? []
                let guestG = data["guestGenres"] as? [String] ?? []
                let hostLikes = data["hostLikes"] as? [Int] ?? []
                let guestLikes = data["guestLikes"] as? [Int] ?? []
                let hostRecent = data["hostRecentActions"] as? [String] ?? []
                let guestRecent = data["guestRecentActions"] as? [String] ?? []

                DispatchQueue.main.async {
                    self.sessionStatus = status
                    self.isHostReady = hReady
                    self.isGuestReady = gReady
                    self.sessionGenres = Set(fetchedGenres)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.partnerRecentActions = isHost ? guestRecent : hostRecent
                    }

                    if (status == "negotiating" || status == "active") && !self.isConnected {
                        self.isConnected = true

                        if isHost {
                            self.partnerName = data["guestName"] as? String
                            self.partnerAvatarBase64 = data["guestAvatar"] as? String
                        } else {
                            self.partnerName = data["hostName"] as? String
                            self.partnerAvatarBase64 = data["hostAvatar"] as? String
                        }
                        self.isHeartBeating = true
                    }
                    
                    let intersection = Set(hostLikes).intersection(Set(guestLikes))
                    let newMatches = intersection.subtracting(self.localDisplayedMatches)
                    
                    if let newMatchId = newMatches.first {
                        self.localDisplayedMatches.insert(newMatchId)
                        self.newlyMatchedMovieId = newMatchId
                    }
                    
                    if status == "negotiating" && fetchedGenres.isEmpty && self.isCurrentUserHost {
                        let hostSet = Set(hostG)
                        let guestSet = Set(guestG)
                        let intersection = hostSet.intersection(guestSet)
                        let commonGenres = intersection.isEmpty ? Array(hostSet.union(guestSet)) : Array(intersection)
                        self.db.collection("sessions").document(code).updateData(["genres": commonGenres])
                    }

                    if status == "negotiating" && hReady && gReady {
                        if self.isCurrentUserHost {
                            self.db.collection("sessions").document(code).updateData(["status": "active"])
                        }
                    }

                    if status == "active" && !self.isSessionActive {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                self.isSessionActive = true
                            }
                        }
                    }
                }
            }
    }
    
    func toggleSessionGenre(_ genre: String) {
        if sessionGenres.contains(genre) {
            sessionGenres.remove(genre)
        } else {
            sessionGenres.insert(genre)
        }
        db.collection("sessions").document(activeSessionCode).updateData([
            "genres": Array(sessionGenres)
        ])
    }
    
    func toggleReadyStatus() {
        let field = isCurrentUserHost ? "hostReady" : "guestReady"
        let newValue = isCurrentUserHost ? !isHostReady : !isGuestReady
        db.collection("sessions").document(activeSessionCode).updateData([field: newValue])
    }

    private func appendRecentAction(_ action: String) -> [String] {
        myRecentActions.append(action)
        if myRecentActions.count > 5 {
            myRecentActions.removeFirst()
        }
        return myRecentActions
    }
    
    func likeMovie(movieId: Int) {
        guard isSessionActive, !activeSessionCode.isEmpty else { return }
        let field = isCurrentUserHost ? "hostLikes" : "guestLikes"
        let recentField = isCurrentUserHost ? "hostRecentActions" : "guestRecentActions"
        let recentArr = appendRecentAction("like")
        
        db.collection("sessions").document(activeSessionCode).updateData([
            field: FieldValue.arrayUnion([movieId]),
            recentField: recentArr
        ])
    }
    
    func dislikeMovie(movieId: Int) {
        guard isSessionActive, !activeSessionCode.isEmpty else { return }
        let field = isCurrentUserHost ? "hostDislikes" : "guestDislikes"
        let recentField = isCurrentUserHost ? "hostRecentActions" : "guestRecentActions"
        let recentArr = appendRecentAction("dislike")
        
        db.collection("sessions").document(activeSessionCode).updateData([
            field: FieldValue.arrayUnion([movieId]),
            recentField: recentArr
        ])
    }

    func favoriteMovie(movieId: Int) {
        guard isSessionActive, !activeSessionCode.isEmpty else { return }
        let field = isCurrentUserHost ? "hostFavorites" : "guestFavorites"
        let recentField = isCurrentUserHost ? "hostRecentActions" : "guestRecentActions"
        let recentArr = appendRecentAction("favorite")
        
        db.collection("sessions").document(activeSessionCode).updateData([
            field: FieldValue.arrayUnion([movieId]),
            recentField: recentArr
        ])
    }

    func trackMovieMetadata(movie: Movie) {
        guard isSessionActive, !activeSessionCode.isEmpty else { return }
        let key = "moviesMetadata.\(movie.id)"
        
        let metadata: [String: Any] = [
            "id": movie.id,
            "title": movie.title,
            "overview": movie.overview,
            "posterPath": movie.posterPath ?? "",
            "voteAverage": movie.voteAverage,
            "releaseDate": movie.releaseDate ?? "",
            "originalLanguage": movie.originalLanguage,
            "genreIds": movie.genreIds ?? []
        ]
        
        db.collection("sessions").document(activeSessionCode).updateData([
            key: metadata
        ])
    }
    
    func leaveSession() {
        let code = activeSessionCode
        listener?.remove()
        listener = nil
        
        if !code.isEmpty {
            let docRef = db.collection("sessions").document(code)
            
            docRef.getDocument { [weak self] snapshot, _ in
                guard let self = self, let data = snapshot?.data() else {
                    self?.resetSessionState()
                    return
                }
                
                var archiveData = data
                archiveData["endedAt"] = Timestamp(date: Date())
                archiveData["status"] = "ended"
                
                let archiveId = UUID().uuidString
                self.db.collection("completed_sessions").document(archiveId).setData(archiveData) { _ in
                    docRef.delete()
                }
            }
        }
        resetSessionState()
    }
    
    func cancelSession() {
        leaveSession()
    }
    
    private func handlePartnerLeft() {
        DispatchQueue.main.async {
            self.listener?.remove()
            self.listener = nil
            self.showPartnerLeftAlert = true
            self.resetSessionState()
        }
    }
    
    private func resetSessionState() {
        DispatchQueue.main.async {
            self.activeSessionCode = ""
            self.showGeneratedCode = false
            self.showInputCode = false
            self.sessionCodeInput = ""
            self.generatedCode = ""
            self.partnerName = nil
            self.partnerAvatarBase64 = nil
            self.isConnected = false
            self.sessionStatus = "none"
            self.sessionGenres.removeAll()
            self.isHostReady = false
            self.isGuestReady = false
            self.newlyMatchedMovieId = nil
            self.localDisplayedMatches.removeAll()

            self.myRecentActions.removeAll()
            self.partnerRecentActions.removeAll()
            
            withAnimation(.spring()) {
                self.isSessionActive = false
                self.isHeartBeating = false
            }
        }
    }

    deinit { listener?.remove() }
}
