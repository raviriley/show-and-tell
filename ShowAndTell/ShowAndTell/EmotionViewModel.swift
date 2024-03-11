//
//  EmotionViewModel.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/18/24.
//

import Foundation

class EmotionViewModel: ObservableObject {
    @Published var name: String = "Concentrated"
    @Published var score: Float = 0.6811225414276123

    func fetchTranslation() {
        let urlString = "https://02dc-2607-f6d0-ced-5b4-f52b-cc3-4158-7247.ngrok-free.app/upload"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.name = "Joy" // Ensure update is on main thread
                    self?.score = 0.6811225414276123
                }
                return
            }

            if let result = try? JSONDecoder().decode(EmotionAPIResponse.self, from: data) {
                DispatchQueue.main.async {
                    self?.name = result.name // Update your model accordingly
                }
            } else {
                DispatchQueue.main.async {
                    self?.name = "na" // Handle decoding error on main thread
                }
            }
        }.resume()
    }
}


// Define your response structure according to your API's schema
struct EmotionAPIResponse: Codable {
    var name: String
    var score: Float
}

