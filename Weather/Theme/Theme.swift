//
//  Theme.swift
//  Weather
//
//  Created by Avinash Kumar on 24/11/24.
//

import SwiftUI

enum Theme {
    case light
    case dark
    
    var backgroundColor: LinearGradient {
        switch self {
        case .light:
            return LinearGradient(
                gradient: Gradient(colors: [.blue, Color("lightBlue")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.3),
                                         Color(red: 0.05, green: 0.05, blue: 0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var textColor: Color {
        switch self {
        case .light, .dark: return .white
        }
    }
    
    var buttonBackground: Color {
        switch self {
        case .light: return .white
        case .dark: return Color(white: 0.2)
        }
    }
    
    var buttonTextColor: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        }
    }
}
