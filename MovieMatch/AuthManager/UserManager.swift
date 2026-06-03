//
//  UserManager.swift
//  MovieMatch
//
//  Created by Ilya on 29.05.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserManager: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var selectedGenres: [String] = []
    @Published var matchesCount: Int = 0
    @Published var sessionsCount: Int = 0
    @Published var swipesCount: Int = 0
    @Published var avatarBase64: String = ""
    
    private let db = Firestore.firestore()
    
    init() {
        loadUser()
    }
    
    func loadUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            DispatchQueue.main.async {
                self.username = data["username"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.selectedGenres = data["genres"] as? [String] ?? []
                self.matchesCount = data["matchesCount"] as? Int ?? 0
                self.sessionsCount = data["sessionCount"] as? Int ?? 0
                self.swipesCount = data["swipesCount"] as? Int ?? 0
                self.avatarBase64 = data["avatarBase64"] as? String ?? ""
            }
        }
    }
    
    func incrementSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).setData(["swipesCount": FieldValue.increment(Int64(1))], merge: true)
        DispatchQueue.main.async { self.swipesCount += 1 }
    }
    
    func incrementMatches() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).setData(["matchesCount": FieldValue.increment(Int64(1))], merge: true)
        DispatchQueue.main.async { self.matchesCount += 1 }
    }
    
    func incrementSessions() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).setData(["sessionCount": FieldValue.increment(Int64(1))], merge: true)
        DispatchQueue.main.async { self.sessionsCount += 1 }
    }
    
    var avatarImage: UIImage? {
        guard !avatarBase64.isEmpty,
              let data = Data(base64Encoded: avatarBase64) else {return nil}
        return UIImage(data: data)
    }
    
    func saveAvatar(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { completion(false); return }
 
        let resized = image.resized(to: CGSize(width: 200, height: 200))
        guard let jpeg = resized.jpegData(compressionQuality: 0.6) else { completion(false); return }
        let base64 = jpeg.base64EncodedString()
 
        db.collection("users").document(uid).updateData(["avatarBase64": base64]) { error in
            DispatchQueue.main.async {
                if error == nil { self.avatarBase64 = base64 }
                completion(error == nil)
            }
        }
    }
    
    var initials: String{
        let parts = username.split(separator: " ").map{String ($0.prefix(1)).uppercased()}
        if parts.count >= 2 {return parts[0] + parts[1]}
        return String(username.prefix(2)).uppercased()
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
