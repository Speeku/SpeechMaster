import SwiftUI
struct TopSpeechCard: View {
    let speech: TopSpeech
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(speech.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 200)
                .cornerRadius(10)
            VStack(alignment: .leading){
                Text(speech.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(speech.description)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }.padding(.bottom,10)
            .frame(width:150)
            .background(Color.black.opacity(0.5))
        }
        .clipShape(.rect(cornerRadius: 10))
        .frame(width: 150)
    }
}
#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing:16) {
            ForEach(0..<20) { _ in
                TopSpeechCard(speech: HomeViewModel().topSpeeches[0])
                TopSpeechCard(speech: HomeViewModel().topSpeeches[1])
            }
        }
 }
//    TopSpeechCard(speech: HomeViewModel().topSpeeches[0])
//    TopSpeechCard(speech: HomeViewModel().topSpeeches[0])
//    TopSpeechCard(speech: HomeViewModel().topSpeeches[0])
}
