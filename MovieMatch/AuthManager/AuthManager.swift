//
//  AuthManager.swift
//  MovieMatch
//
//  Created by Ilya on 20.04.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager : ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    let dataBase = Firestore.firestore()
    
    func registerUser(email: String, password: String, username: String){
        Auth.auth().createUser(withEmail: email, password: password){
            result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            guard let userUid = result?.user.uid else { return }
            
            let userData: [String: Any] = [
                "id": userUid,
                "username": username,
                "email": email,
                "dataCreated": Timestamp(date: Date()),
                "password": password
            ]
            
            self.dataBase.collection("users").document(userUid).setData(userData) { error in
                if let error = error{
                    print("Епта. Косяк с базой данных")
                } else {
                    print("Ооо. В базу созранили")
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }
    
    func loginUser(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password){
            result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            DispatchQueue.main.async{
                self.isAuthenticated = true
            }
        }
    }
    
}
