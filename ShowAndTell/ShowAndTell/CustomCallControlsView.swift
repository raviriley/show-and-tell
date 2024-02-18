//
//  CustomCallControlsView.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/17/24.
//

import SwiftUI
import StreamVideoSwiftUI

struct CustomCallControlsView: View {
    @ObservedObject var viewModel: CallViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    let cameraFeedManager = CameraFeedManager()
    
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
            cameraFeedManager.captureImage { image in
                            guard let image = image, let imageData = image.jpegData(compressionQuality: 0.5) else { return }
                            let base64ImageString = imageData.base64EncodedString()
                            uploadImage(base64EncodedString: base64ImageString)
                        }
            appViewModel.isOverlayVisible.toggle() // Toggle overlay visibility
        }) {
            Image(systemName: "camera.circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 44))
        }
    }
    
    func uploadImage(base64EncodedString: String) {
        let uploadData = ["image": base64EncodedString]
        let url = URL(string: "https://02dc-2607-f6d0-ced-5b4-f52b-cc3-4158-7247.ngrok-free.app/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: uploadData, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during HTTP request: \(error.localizedDescription)")
                return
            }
            // Check the response status code and handle accordingly
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Image uploaded successfully")
            } else {
                print("Failed to upload image")
            }
        }.resume()
    }
}
