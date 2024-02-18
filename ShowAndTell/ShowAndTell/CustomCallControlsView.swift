//
//  CustomCallControlsView.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/17/24.
//

import SwiftUI
import Combine
import StreamVideo
import StreamVideoSwiftUI

struct CustomCallControlsView: View {
    @ObservedObject var viewModel: CallViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @Injected(\.snapshotTrigger) var snapshotTrigger // Assuming StreamVideo's DI setup
        
        var body: some View {
            HStack(spacing: 32) {
                VideoIconView(viewModel: viewModel)
                MicrophoneIconView(viewModel: viewModel)
                ToggleCameraIconView(viewModel: viewModel)
                imageCaptureButton
                HangUpIconView(viewModel: viewModel)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
        }
        
        private var imageCaptureButton: some View {
            Button(action: {
                snapshotTrigger.capture()
            }) {
                Image(systemName: "camera.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 44))
            }
        }
}
