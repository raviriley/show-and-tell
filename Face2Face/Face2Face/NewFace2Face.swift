import SwiftUI
import StreamVideoSwiftUI
struct NewFace2Face: View {
    @ObservedObject var viewModel: CallViewModel
    private let callId: String = "imirKfxKjuXC"
    
    var body: some View {
        NavigationStack {
            ZStack {
                HostedViewController()
                    .ignoresSafeArea()
                    .blur(radius: 8)
                    .blendMode(.plusLighter)
                
                VStack {
                    HStack{
                        NavigationLink {
                            
                        } label: {
                            VStack {
                                Image(systemName: "link")
                                Text("Create Link")
                                    .lineLimit(1)
                            }
                            .padding(EdgeInsets(top: 7, leading: 42,
                                                bottom: 7, trailing: 42))
                        }
                        .buttonStyle(.plain)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        
                        NavigationLink {
                            //
                        } label: {
                            VStack {
                                Image(systemName: "video.fill")
                                Text("New Face2Face")
                                    .lineLimit(1)
                            }
                            .padding(.horizontal)
                            .accessibilityAddTraits(.isButton)
                            .onTapGesture {
                                Task {
                                    guard viewModel.call == nil else { return }
                                    viewModel.joinCall(callType: .default, callId: callId)
                                }
                            }
                            
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.bottom, 44)
                    
                    List {
                        Section{
                            
                        } header: {
                            Text("Today")
                        }
                        NavigationLink {
                            
                        } label: {
                            HStack {
                                Image(systemName: "h.circle.fill")
                                    .font(.largeTitle)
                                
                                VStack(alignment: .leading) {
                                    Text("Harrison")
                                    HStack {
                                        Image(systemName: "video.fill")
                                        Text("Face2Face Video")
                                    }
                                }
                                
                                Spacer()
                                
                                Text("12:03")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .padding()
                .navigationTitle("Face2Face")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            
                        } label: {
                            Text("Edit")
                        }
                    }
                }
            }
        }
    }
}
