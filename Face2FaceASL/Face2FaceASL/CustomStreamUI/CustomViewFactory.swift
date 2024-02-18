//
//  CustomViewFactory.swift
//  Face2FaceASL
//
//  Created by Ravi Riley on 2/17/24.
//

import StreamVideoSwiftUI
import SwiftUI


class CustomViewFactory: ViewFactory {

    public func makeCallControlsView(viewModel: CallViewModel) -> some View {
        EmptyCallControlsView(viewModel: viewModel)
//        CustomCallControlsView(viewModel: viewModel)
//        FBCallControlsView(viewModel: viewModel)
    }
    
    public func makeCallTopView(viewModel: CallViewModel) -> some View {
        EmptyCallTopView(viewModel: viewModel)
    }

}

struct EmptyCallControlsView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        EmptyView()
    }
    
}

struct EmptyCallTopView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        EmptyView()
    }
    
}

struct FBCallControlsView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        HStack() {

            VideoIconView(viewModel: viewModel)
            
            Spacer()

            MicrophoneIconView(viewModel: viewModel)
            
            Spacer()
                        
            ToggleCameraIconView(viewModel: viewModel)
            
            Spacer()
            
            HangUpIconView(viewModel: viewModel)
        }
        .foregroundColor(.white)
//        .padding(.vertical, 8)
//        .padding(.horizontal)
        .modifier(BackgroundModifier())
//        .padding(.horizontal, 32)
    }
    
}

struct BackgroundModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 24)
                )
        } else {
            content
                .background(Color.black.opacity(0.8))
                .cornerRadius(24)
        }
    }
    
}

