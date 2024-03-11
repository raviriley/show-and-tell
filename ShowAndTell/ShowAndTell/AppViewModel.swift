//
//  AppViewModel.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/18/24.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var isOverlayVisible: Bool = false
    @Published var EmotionResponse: EmotionResponse?
}

struct EmotionResponse: Codable {
    let name: String
    let score: Float
}
