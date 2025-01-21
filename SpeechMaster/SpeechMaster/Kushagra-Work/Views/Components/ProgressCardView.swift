import SwiftUI
struct ProgressCardView: View {
    
    let title: String
    let progress: Double
    let fgColor: Color
    let bgColor: Color
    let circleColor: Color
    let lastCreatedScriptName: String?
    /*init(title: String, progress: Double, color: Color) {
        self.title = title
        self.progress = progress
        self.color = color
        self.lastCreatedScriptName = nil
    }
    init (title: String, progress: Double, color: Color, lastCreatedScriptName: String?) {
        self.title = title
        self.progress = progress
        self.color = color
        self.lastCreatedScriptName*/
    var body: some View {
        VStack(alignment: .leading,spacing:2){
            Text(title)
                .foregroundStyle(fgColor)
                .font(.headline)
                .lineLimit(2)
            HStack{
                VStack(alignment: .leading){
                    if let lastScriptName = lastCreatedScriptName{ Text(lastScriptName)
                            .font(.subheadline)
                            .foregroundStyle(fgColor)
                            .frame(maxWidth:.infinity)
                            .lineLimit(1)
                            .padding(.trailing,3)
                    }
                    else{
                        Spacer()
                        //Text("").frame(maxWidth:.infinity)
                    }
                    Text("\(Int(progress))%")
                        .font(.subheadline)
                    .foregroundStyle(fgColor)}
                ZStack {
                    Circle()
                        .stroke(lineWidth: 7)
                        .foregroundColor(.white)
                    
                    Circle()
                        .trim(from: 0, to: progress/100)
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .butt))
                        .foregroundColor(circleColor)
                        .rotationEffect(.degrees(-90))
                        //.bold()
                }
                .frame(width: 50, height: 50)
            }}
        .padding()
        .background(bgColor)
        .cornerRadius(15)
        .frame(maxHeight: .infinity)
    }
} 
#Preview {
    @Previewable @StateObject var viewModel = HomeViewModel()
    HStack(spacing:16){ProgressCardView(title: "Audience Engagement", progress: 50, fgColor: .white ,bgColor: .progressCardColorAudienceEngagement, circleColor: .orange, lastCreatedScriptName: viewModel.scripts.first?.title ?? nil)
        ProgressCardView(title: "Overall Improvement", progress: 34, fgColor: .black ,bgColor: .progressCardColorOverallImprovement, circleColor: .green,lastCreatedScriptName:"Computer Science Network")
    }.padding()
    
}
//(String(format: "%.2f", progress)
