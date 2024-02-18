import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

@main
struct VideoCallApp: App {
    @ObservedObject var viewModel: CallViewModel

    private var client: StreamVideo
    private let apiKey: String = "89eqkz78mgm3" // The API key can be found in the Credentials section
    private let userId: String = "REPLACE_WITH_USER_ID" // The User Id can be found in the Credentials section
    private let token: String = "xu9htyf96a3mt4mpcuaw6txm4p8hvcgawgqwzp49tc8d6mg38bhd6zertbduhdj2" // The Token can be found in the Credentials section
    let callId: String = "imirKfxKjuXC" // The CallId can be found in the Credentials section

    init() {
        let user = User(
            id: userId,
            name: "Martin", // name and imageURL are used in the UI
            imageURL: .init(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/a3911/martin-mitrevski.webp")
        )

        // Initialize Stream Video client
        self.client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )

        self.viewModel = .init()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ZStack {
                    VStack {
                        if viewModel.call != nil {
                            CallContainer(viewFactory: DefaultViewFactory.shared, viewModel: viewModel)
                        } else {
                            NewFace2Face(viewModel: viewModel)
                        }
                    }
                }
            }
        }
    }
}
