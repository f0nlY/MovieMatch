//
//  LoginModifier.swift
//  MovieMatch
//
//  Created by Ilya on 19.04.2026.
//

import SwiftUI

struct CustomFieldStyleLogin: ViewModifier{
    func body(content: Content) -> some View{
        content
            .padding()
            .background(Color.black.opacity(0.7))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.purple, lineWidth: 4))
            .frame(width: 350, height: 55)
            .clipShape(.rect(cornerRadius: 10))
    }
}

extension View{
    func customFieldStyleLogin() -> some View{
        self.modifier(CustomFieldStyleLogin())
    }
}
