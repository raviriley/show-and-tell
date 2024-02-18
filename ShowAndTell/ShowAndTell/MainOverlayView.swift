//
//  MainOverlayView.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/18/24.
//

import SwiftUI

struct MainOverlayView: View {
    @Binding var isVisible: Bool
    
    let sw = UIScreen.main.bounds.width / 393
    let sh = UIScreen.main.bounds.height / 852
    
    var body: some View {
        if isVisible {
            Text("Overlay Text Here for ASL Translation")
                .padding()
                .background(Color.white.opacity(0.90))
                .foregroundColor(.black)
                .cornerRadius(10)
                .padding()
            
        }
    }
}
