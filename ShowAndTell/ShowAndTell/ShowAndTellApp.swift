//
//  ShowAndTellApp.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/18/24.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

@main
struct ShowAndTellApp: App {
    @ObservedObject var viewModel: CallViewModel
    @StateObject private var appViewModel = AppViewModel()
    
    @Injected(\.snapshotTrigger) var snapshotTrigger

    private var client: StreamVideo
    private let apiKey: String = "mmhfdzb5evj2" // The API key can be found in the Credentials section
    private let userId: String = "Ravi" // The User Id can be found in the Credentials section
    private let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRW1wZXJvcl9QYWxwYXRpbmUiLCJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0VtcGVyb3JfUGFscGF0aW5lIiwiaWF0IjoxNzA4MjQwNzIxLCJleHAiOjE3MDg4NDU1MjZ9.XM8eXUOBQIZfywBM_neZmZfhWugWZePj26Tr449Uc4I" // The Token can be found in the Credentials section
    private let callId: String = "NUop3MrLTvMU" // The CallId can be found in the Credentials section

    init() {
        let user = User(
            id: userId,
            name: "Ravi", // name and imageURL are used in the UI
            imageURL: .init(string: "https://www.notion.so/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Febddc562-2a7e-411f-848c-daa8a2aa65d4%2Fportrait_-_new.png?table=block&id=39537581-2835-4367-8949-2b1e54bb7bfe&cache=v2")
        )

        // Initialize Stream Video client
        self.client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )

        self.viewModel = .init()
    }
    
//    let cameraFeedManager = CameraFeedManager()

    var body: some Scene {
        WindowGroup {
            ZStack {
                VStack {
                    if viewModel.call != nil {
                        CallContainer(viewFactory: CustomViewFactory(), viewModel: viewModel).snapshot(trigger: snapshotTrigger) { snapshot in
                            guard let imageData = snapshot.jpegData(compressionQuality: 0.5) else {
                                print("Failed to convert snapshot to JPEG.")
                                return
                            }
                            let base64ImageString = imageData.base64EncodedString()
                            let response = uploadImage(base64EncodedString: base64ImageString)
                            print("response: ", response)

                        }
                            .overlay(
                                GeometryReader { geometry in
                                        VStack {
                                            MainOverlayView(isVisible: $appViewModel.isOverlayVisible)
                                                .frame(width: geometry.size.width, height: 50, alignment: .top) // Adjust the height as needed
                                            Spacer()
                                        }
                                    }
                            )
                    } else {
                        Text("loading...")
                    }
                }.onAppear {
                    Task {
                        guard viewModel.call == nil else { return }
                        viewModel.joinCall(callType: .default, callId: callId)
                    }
                }
                .environmentObject(appViewModel)
//                .environmentObject(cameraFeedManager)
            }
        }
    }
}
