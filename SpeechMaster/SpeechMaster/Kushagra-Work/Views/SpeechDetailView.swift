import SwiftUI
import WebKit

struct SpeechDetailView: View {
    let speech: TopSpeech
    @ObservedObject var viewModel: VideoPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        //NavigationView{
        ScrollView{
            VStack(alignment: .leading,spacing:20) {
                // Video Player
                GeometryReader { geometry in
                                    VideoPlayerView(urlString: viewModel.videoDetails[speech.imageName]?.videoURL ?? "")
                                        .frame(
                                            width: geometry.size.width,
                                            height: geometry.size.width * 9 / 16
                                        )
                                        .clipped()
                                }
                                .frame(height: UIScreen.main.bounds.width * 9 / 16)
                Text("\(speech.description)")
                    .font(.title2).bold().padding().toolbarTitleDisplayMode(.inline)
                // Summary Section
                VStack(alignment: .leading, spacing:10) {
                    Text("Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal,13)
                    
                    ForEach(viewModel.videoDetails[speech.imageName]?.summary ?? []) { section in
                        TimeStampSectionView(section: section)
                    }.padding(.leading,18)
                }//.padding(.top,)
            }.navigationTitle(speech.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct VideoPlayerView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedHTML = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body { margin: 0; background-color: black; }
                .video-container { position: relative; padding-bottom: 56.25%; height: 0; }
                iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe src="\(urlString)?playsinline=1&autoplay=1" frameborder="0" allowfullscreen></iframe>
            </div>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
}

/*struct VideoPlayerView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}*/

struct TimeStampSectionView: View {
    let section: TimeStampSection
    @State private var showDetails = false
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            HStack {
                Text(section.timeRange)
                    .foregroundColor(.blue)
                    .frame(width: 100, alignment: .leading)
                Text(section.title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showDetails) {
            SectionDetailView(details: section.details, title: section.title)
        }
    }
}

struct SectionDetailView: View {
    let details: SectionDetails
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DetailSection(title: "Body Language", content: details.bodyLanguage)
                    DetailSection(title: "Adaptation Tip", content: details.adaptationTip)
                    if let speech = details.speech {
                        DetailSection(title: "Speech", content: speech)
                    }
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
        }
    }
}

#Preview {
        SpeechDetailView(
            speech: TopSpeech(
                title: "Steve Jobs",
                description: "iPhone Presentation",
                imageName: "steve_jobs"
            ),
            viewModel: VideoPlayerViewModel()
        )
    }
