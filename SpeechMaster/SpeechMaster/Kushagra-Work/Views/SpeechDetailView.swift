import SwiftUI
import WebKit

struct SpeechDetailView: View {
    let speech: TopSpeech
    @ObservedObject var viewModel: VideoPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingShareSheet = false
    @State private var isBookmarked = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Video Player Section
                videoPlayerSection
                
                // Content Section
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Analysis Content
                    if let details = viewModel.videoDetails[speech.imageName] {
                        ForEach(details.summary) { section in
                            AnalysisSectionCard(section: section)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let videoURL = viewModel.videoDetails[speech.imageName]?.videoURL,
               let url = URL(string: videoURL) {
                ShareSheet(items: [url])
            } else {
                ShareSheet(items: [speech.title]) // Fallback to sharing just the title if URL is invalid
            }
        }
    }
    
    // MARK: - Video Player Section
    private var videoPlayerSection: some View {
        GeometryReader { geometry in
            VideoPlayerView(urlString: viewModel.videoDetails[speech.imageName]?.videoURL ?? "")
                .frame(width: geometry.size.width, height: geometry.size.width * 9 / 16)
                .overlay(alignment: .bottomTrailing) {
                    qualityBadge
                }
        }
        .frame(height: UIScreen.main.bounds.width * 9 / 16)
    }
    
    private var qualityBadge: some View {
        Text("HD")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.6))
            .cornerRadius(4)
            .padding(8)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(speech.title)
                .font(.title2)
                .fontWeight(.bold)
            Text(speech.description)
            HStack(spacing: 16) {
                statsView(icon: "calendar", value: "\(speech.year)")
                statsView(icon: "clock", value: formatDuration(speech.duration))
            }
            
            // Tags ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(speech.tags, id: \.self) { tag in
                        TagView(text: tag)
                    }
                }
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Helper Views
    private func statsView(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(value)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
    
    // MARK: - Helper Functions
    private func formatViewCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes)min"
    }
}

// MARK: - Supporting Views
struct CustomSegmentedControl: View {
    @Binding var selection: Int
    let items: [String]
    
    var body: some View {
        HStack {
            ForEach(0..<items.count, id: \.self) { index in
                VStack(spacing: 8) {
                    Text(items[index])
                        .font(.subheadline)
                        .fontWeight(selection == index ? .semibold : .regular)
                        .foregroundColor(selection == index ? .primary : .secondary)
                    
                    Rectangle()
                        .fill(selection == index ? Color.accentColor : Color.clear)
                        .frame(height: 2)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selection = index
                    }
                }
            }
        }
    }
}

struct TagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
}

struct AnalysisSectionCard: View {
    let section: TimeStampSection
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() }}) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.headline)
                        Text(section.timeRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    analysisRow(title: "Body Language", content: section.details.bodyLanguage, icon: "person.fill")
                    analysisRow(title: "Adaptation Tip", content: section.details.adaptationTip, icon: "lightbulb.fill")
                    if let speech = section.details.speech {
                        analysisRow(title: "Speech", content: speech, icon: "text.bubble.fill")
                    }
                    
                    // Keywords
                    if !section.details.keywords.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Keywords")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(section.details.keywords, id: \.self) { keyword in
                                    TagView(text: keyword)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.5), radius: 4, x: 0, y: 2)
    }
    
    private func analysisRow(title: String, content: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(content)
                .font(.body)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return computeSize(rows: rows, proposal: proposal)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        placeViews(in: bounds, rows: rows)
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var currentRow: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        var currentX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > (proposal.width ?? 0) {
                rows.append(currentRow)
                currentRow = [subview]
                currentX = size.width + spacing
            } else {
                currentRow.append(subview)
                currentX += size.width + spacing
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private func computeSize(rows: [[LayoutSubviews.Element]], proposal: ProposedViewSize) -> CGSize {
        var height: CGFloat = 0
        var width: CGFloat = 0
        
        for row in rows {
            var rowWidth: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                rowWidth += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            
            width = max(width, rowWidth)
            height += rowHeight + spacing
        }
        
        return CGSize(width: width - spacing, height: height - spacing)
    }
    
    private func placeViews(in bounds: CGRect, rows: [[LayoutSubviews.Element]]) {
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            
            y += rowHeight + spacing
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - VideoPlayerView
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

// MARK: - TimeStampSectionView
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
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color(.systemGray4).opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            sectionRow(title: "Body Language", content: section.details.bodyLanguage, icon: "person.fill")
                            sectionRow(title: "Adaptation Tip", content: section.details.adaptationTip, icon: "lightbulb.fill")
                            if let speech = section.details.speech {
                                sectionRow(title: "Speech Content", content: speech, icon: "text.bubble.fill")
                            }
                        }
                        .padding(.horizontal)
                        
                        if !section.details.keywords.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Keywords")
                                    .font(.headline)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(section.details.keywords, id: \.self) { keyword in
                                            TagView(text: keyword)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle(section.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showDetails = false }
                    }
                }
            }
        }
    }
    
    private func sectionRow(title: String, content: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
            Text(title)
                .font(.headline)
            }
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        SpeechDetailView(
            speech: TopSpeech(
                title: "Steve Jobs",
                description: "iPhone Presentation",
                imageName: "steve_jobs",
                category: .technology,
                year: 2007,
                duration: 2220,
                tags: ["innovation", "product launch", "technology"],
                isFeatured: true
            ),
            viewModel: VideoPlayerViewModel()
        )
    }
    }
