import Foundation

class HomeViewModel: ObservableObject {
    @Published var userName: String = "Piyush"
    @Published var isLoggedIn: Bool = true
    @Published var scripts: [Script] = [
        Script(title: "Introduction", date: Date(), isPinned: false),
        Script(title: "Scene 1", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), isPinned: false),
        Script(title: "Scene 2", date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), isPinned: false),
        Script(title: "Conclusion", date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), isPinned: false)
    ]
    
    @Published var searchText: String = ""
    @Published var audienceEngagement: Double = 0
    @Published var overallImprovement: Double = 0
    @Published var navigateToPiyushScreen = false
    @Published var uploadedScriptText = ""
    
    // MARK: - Script Management
    
    func addScript(_ script: Script) {
        DispatchQueue.main.async {
            self.scripts.append(script)
            self.sortScripts()
        }
    }
    
    func deleteScript(_ script: Script) {
        DispatchQueue.main.async {
            self.scripts.removeAll { $0.id == script.id }
            self.sortScripts()
        }
    }
    
    func deleteScript(at indexSet: IndexSet) {
        DispatchQueue.main.async {
            self.scripts.remove(atOffsets: indexSet)
            self.sortScripts()
        }
    }
    
    func pinToTop(_ script: Script) {
        if let index = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[index].isPinned = true
            sortScripts()
        }
    }
    
    func unpinScript(_ script: Script) {
        if let index = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[index].isPinned = false
            sortScripts()
        }
    }
    
    func togglePin(for script: Script) {
        DispatchQueue.main.async {
            if let index = self.scripts.firstIndex(where: { $0.id == script.id }) {
                self.scripts[index].isPinned.toggle()
                self.sortScripts()
            }
        }
    }
    
    private func sortScripts() {
        scripts.sort { (script1, script2) in
            if script1.isPinned && !script2.isPinned {
                return true
            }
            if !script1.isPinned && script2.isPinned {
                return false
            }
            return script1.date > script2.date
        }
        objectWillChange.send()
    }
    
    func isScriptsEmpty() -> Bool {
        return scripts.isEmpty || !isLoggedIn
    }
    
    // MARK: - Top Speeches
    
    let topSpeeches: [TopSpeech] = [
        TopSpeech(
            title: "Steve Jobs",
            description: "Unveiling the iPhone (2007)",
            imageName: "steve_jobs"
        ),
        TopSpeech(
            title: "Barack Obama",
            description: "Speech on Education (2004)",
            imageName: "barack_obama"
        ),
        TopSpeech(
            title: "Roger Federer",
            description: "Cambridge Union Speech (2019)",
            imageName: "roger_federer"
        ),
        TopSpeech(
            title: "Martin Luther King Jr.",
            description: "I Have a Dream (1963)",
            imageName: "martin_luther_king"
        ),
        TopSpeech(
            title: "Simon Sinek",
            description: "How Great Leaders Inspire Action (2009)",
            imageName: "simon_sinek"
        ),
        TopSpeech(
            title: "Brene Brown",
            description: "The Power of Vulnerability (2010)",
            imageName: "brene_brown"
        ),
        TopSpeech(
            title: "Elon Musk",
            description: "Tesla and SpaceX Vision Presentation (2016)",
            imageName: "elon_musk"
        ),
        TopSpeech(
            title: "Malala Yousafzai",
            description: "UN Youth Assembly Speech (2013)",
            imageName: "malala_yousafzai"
        ),
        TopSpeech(
            title: "J.K. Rowling",
            description: "Harvard Commencement Speech (2008)",
            imageName: "jk_rowling"
        ),
        TopSpeech(
            title: "Winston Churchill",
            description: "We Shall Fight on the Beaches (1940)",
            imageName: "winston_churchill"
        )
    ]
}
