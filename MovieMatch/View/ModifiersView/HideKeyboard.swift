//
//  HideKeyboard.swift
//  MovieMatch
//
//  Created by Ilya on 29.05.2026.
//

import SwiftUI

extension View{
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

