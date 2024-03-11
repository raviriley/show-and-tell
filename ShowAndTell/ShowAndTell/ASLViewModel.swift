//
//  ASLViewModel.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/18/24.
//

import Foundation

class LanguageViewModel: ObservableObject {
    @Published var responseText: String = "Emotion: 😄 Concentrated | ASL: hello"

    func fetchTranslation() {
        let urlString = "https://9530-171-66-13-235.ngrok-free.app/get_spoken_text" // Your API endpoint
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.responseText = "Emotion: 😁" // Ensure update is on main thread
                }
                return
            }

            if let result = try? JSONDecoder().decode(LanguageAPIResponse.self, from: data) {
                DispatchQueue.main.async {
                    self?.responseText = result.spokenText // Update your model accordingly
                }
            } else {
                DispatchQueue.main.async {
                    self?.responseText = "Emotion: 😁 Happy" // Handle decoding error on main thread
                }
            }
        }.resume()
    }
}


// Define your response structure according to your API's schema
struct LanguageAPIResponse: Codable {
    var spokenText: String
}
