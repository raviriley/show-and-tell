//
//  CustomViewFactory.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/17/24.
//

import StreamVideoSwiftUI
import SwiftUI


class CustomViewFactory: ViewFactory {

    public func makeCallControlsView(viewModel: CallViewModel) -> some View {
//        EmptyCallControlsView(viewModel: viewModel)
        CustomCallControlsView(viewModel: viewModel)
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
        Text("Overlay Text Here for ASL Translation")
            .padding()
//            .background(Color.black.opacity(0))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
//        EmptyView()
    }
    
}
