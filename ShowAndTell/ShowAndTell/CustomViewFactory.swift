//
//  CustomViewFactory.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/17/24.
//

import SwiftUI
import Combine
import StreamVideo
import StreamVideoSwiftUI


class CustomViewFactory: ViewFactory {
    @Injected(\.snapshotTrigger) var snapshotTrigger

    public func makeCallControlsView(viewModel: CallViewModel) -> some View {
        CustomCallControlsView(viewModel: viewModel)
    }
    
    public func makeCallTopView(viewModel: CallViewModel) -> some View {
        CustomCallTopView(viewModel: viewModel)
    }

}

func uploadImage(base64EncodedString: String) {
        let uploadData = ["image": base64EncodedString]
        guard let url = URL(string: "https://02dc-2607-f6d0-ced-5b4-f52b-cc3-4158-7247.ngrok-free.app/upload") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: uploadData, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during HTTP request: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Image uploaded successfully")
//                print(data)
            } else {
                print("Failed to upload image")
            }
        }.resume()
}

func extractTopEmotion(from response: [String: Any]) -> String? {
    guard let emotionData = response["emotion"] as? [String: Any], // Directly access the 'emotion' dictionary
          let emotionName = emotionData["name"] as? String // Extract the 'name' of the emotion
    else {
        print("Failed to extract top emotion from response.")
        return nil
    }
    
    return emotionName
}q


struct EmptyCallControlsView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        EmptyView()
    }
    
}

struct CustomCallTopView: View {
    @ObservedObject var viewModel: CallViewModel
        @StateObject private var languageViewModel = LanguageViewModel()

        var body: some View {
            Text(languageViewModel.responseText)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                .onAppear {
                    languageViewModel.fetchTranslation()
                }
        }
}
