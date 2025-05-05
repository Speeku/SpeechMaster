import SwiftUI

extension Color {
    // App background color that adapts to dark mode
    static var customAppBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor.black.withAlphaComponent(0.9) : 
                UIColor.white
        })
    }
    
    // Text primary color that adapts to dark mode
    static var textPrimary: Color {
        Color(uiColor: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor.white : 
                UIColor.black
        })
    }
    
    // Text secondary color that adapts to dark mode
    static var textSecondary: Color {
        Color(uiColor: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor.white.withAlphaComponent(0.7) : 
                UIColor.black.withAlphaComponent(0.6)
        })
    }
    
    // Card background color that adapts to dark mode
    static var cardBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor.systemGray6 : 
                UIColor.white
        })
    }
} 