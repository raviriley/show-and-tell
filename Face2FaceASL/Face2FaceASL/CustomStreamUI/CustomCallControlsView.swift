//
//  CustomCallControlsView.swift
//  Face2FaceASL
//
//  Created by Ravi Riley on 2/17/24.
//

import SwiftUI
import StreamVideoSwiftUI

struct CustomCallControlsView: View {

    @ObservedObject var viewModel: CallViewModel

    var body: some View {
        HStack(spacing: 32) {
            VideoIconView(viewModel: viewModel)
            MicrophoneIconView(viewModel: viewModel)
            ToggleCameraIconView(viewModel: viewModel)
            HangUpIconView(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 85)
    }
}
