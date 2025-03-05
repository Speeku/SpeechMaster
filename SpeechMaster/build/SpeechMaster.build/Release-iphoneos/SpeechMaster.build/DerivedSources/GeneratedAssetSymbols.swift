import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AppBackground" asset catalog color resource.
    static let appBackground = DeveloperToolsSupport.ColorResource(name: "AppBackground", bundle: resourceBundle)

    /// The "ProgressCardColorAudienceEngagement" asset catalog color resource.
    static let progressCardColorAudienceEngagement = DeveloperToolsSupport.ColorResource(name: "ProgressCardColorAudienceEngagement", bundle: resourceBundle)

    /// The "ProgressCardColorOverallImprovement" asset catalog color resource.
    static let progressCardColorOverallImprovement = DeveloperToolsSupport.ColorResource(name: "ProgressCardColorOverallImprovement", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "AE" asset catalog image resource.
    static let AE = DeveloperToolsSupport.ImageResource(name: "AE", bundle: resourceBundle)

    /// The "BMP" asset catalog image resource.
    static let BMP = DeveloperToolsSupport.ImageResource(name: "BMP", bundle: resourceBundle)

    /// The "CDGKNSTXYZ" asset catalog image resource.
    static let CDGKNSTXYZ = DeveloperToolsSupport.ImageResource(name: "CDGKNSTXYZ", bundle: resourceBundle)

    /// The "FW" asset catalog image resource.
    static let FW = DeveloperToolsSupport.ImageResource(name: "FW", bundle: resourceBundle)

    /// The "Highlights" asset catalog image resource.
    static let highlights = DeveloperToolsSupport.ImageResource(name: "Highlights", bundle: resourceBundle)

    /// The "L" asset catalog image resource.
    static let L = DeveloperToolsSupport.ImageResource(name: "L", bundle: resourceBundle)

    /// The "O" asset catalog image resource.
    static let O = DeveloperToolsSupport.ImageResource(name: "O", bundle: resourceBundle)

    /// The "QW" asset catalog image resource.
    static let QW = DeveloperToolsSupport.ImageResource(name: "QW", bundle: resourceBundle)

    /// The "R" asset catalog image resource.
    static let R = DeveloperToolsSupport.ImageResource(name: "R", bundle: resourceBundle)

    /// The "TH" asset catalog image resource.
    static let TH = DeveloperToolsSupport.ImageResource(name: "TH", bundle: resourceBundle)

    /// The "app_logo" asset catalog image resource.
    static let appLogo = DeveloperToolsSupport.ImageResource(name: "app_logo", bundle: resourceBundle)

    /// The "barack_obama" asset catalog image resource.
    static let barackObama = DeveloperToolsSupport.ImageResource(name: "barack_obama", bundle: resourceBundle)

    /// The "brene_brown" asset catalog image resource.
    static let breneBrown = DeveloperToolsSupport.ImageResource(name: "brene_brown", bundle: resourceBundle)

    /// The "elon_musk" asset catalog image resource.
    static let elonMusk = DeveloperToolsSupport.ImageResource(name: "elon_musk", bundle: resourceBundle)

    /// The "graph" asset catalog image resource.
    static let graph = DeveloperToolsSupport.ImageResource(name: "graph", bundle: resourceBundle)

    /// The "jk_rowling" asset catalog image resource.
    static let jkRowling = DeveloperToolsSupport.ImageResource(name: "jk_rowling", bundle: resourceBundle)

    /// The "launch_screen" asset catalog image resource.
    static let launchScreen = DeveloperToolsSupport.ImageResource(name: "launch_screen", bundle: resourceBundle)

    /// The "malala_yousafzai" asset catalog image resource.
    static let malalaYousafzai = DeveloperToolsSupport.ImageResource(name: "malala_yousafzai", bundle: resourceBundle)

    /// The "martin_luther_king" asset catalog image resource.
    static let martinLutherKing = DeveloperToolsSupport.ImageResource(name: "martin_luther_king", bundle: resourceBundle)

    /// The "pitchGraph" asset catalog image resource.
    static let pitchGraph = DeveloperToolsSupport.ImageResource(name: "pitchGraph", bundle: resourceBundle)

    /// The "roger_federer" asset catalog image resource.
    static let rogerFederer = DeveloperToolsSupport.ImageResource(name: "roger_federer", bundle: resourceBundle)

    /// The "simon_sinek" asset catalog image resource.
    static let simonSinek = DeveloperToolsSupport.ImageResource(name: "simon_sinek", bundle: resourceBundle)

    /// The "steve_jobs" asset catalog image resource.
    static let steveJobs = DeveloperToolsSupport.ImageResource(name: "steve_jobs", bundle: resourceBundle)

    /// The "winston_churchill" asset catalog image resource.
    static let winstonChurchill = DeveloperToolsSupport.ImageResource(name: "winston_churchill", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AppBackground" asset catalog color.
    static var appBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appBackground)
#else
        .init()
#endif
    }

    /// The "ProgressCardColorAudienceEngagement" asset catalog color.
    static var progressCardColorAudienceEngagement: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .progressCardColorAudienceEngagement)
#else
        .init()
#endif
    }

    /// The "ProgressCardColorOverallImprovement" asset catalog color.
    static var progressCardColorOverallImprovement: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .progressCardColorOverallImprovement)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AppBackground" asset catalog color.
    static var appBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .appBackground)
#else
        .init()
#endif
    }

    /// The "ProgressCardColorAudienceEngagement" asset catalog color.
    static var progressCardColorAudienceEngagement: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .progressCardColorAudienceEngagement)
#else
        .init()
#endif
    }

    /// The "ProgressCardColorOverallImprovement" asset catalog color.
    static var progressCardColorOverallImprovement: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .progressCardColorOverallImprovement)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "AppBackground" asset catalog color.
    static var appBackground: SwiftUI.Color { .init(.appBackground) }

    /// The "ProgressCardColorAudienceEngagement" asset catalog color.
    static var progressCardColorAudienceEngagement: SwiftUI.Color { .init(.progressCardColorAudienceEngagement) }

    /// The "ProgressCardColorOverallImprovement" asset catalog color.
    static var progressCardColorOverallImprovement: SwiftUI.Color { .init(.progressCardColorOverallImprovement) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AppBackground" asset catalog color.
    static var appBackground: SwiftUI.Color { .init(.appBackground) }

    /// The "ProgressCardColorAudienceEngagement" asset catalog color.
    static var progressCardColorAudienceEngagement: SwiftUI.Color { .init(.progressCardColorAudienceEngagement) }

    /// The "ProgressCardColorOverallImprovement" asset catalog color.
    static var progressCardColorOverallImprovement: SwiftUI.Color { .init(.progressCardColorOverallImprovement) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "AE" asset catalog image.
    static var AE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AE)
#else
        .init()
#endif
    }

    /// The "BMP" asset catalog image.
    static var BMP: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BMP)
#else
        .init()
#endif
    }

    /// The "CDGKNSTXYZ" asset catalog image.
    static var CDGKNSTXYZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CDGKNSTXYZ)
#else
        .init()
#endif
    }

    /// The "FW" asset catalog image.
    static var FW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FW)
#else
        .init()
#endif
    }

    /// The "Highlights" asset catalog image.
    static var highlights: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .highlights)
#else
        .init()
#endif
    }

    /// The "L" asset catalog image.
    static var L: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .L)
#else
        .init()
#endif
    }

    /// The "O" asset catalog image.
    static var O: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .O)
#else
        .init()
#endif
    }

    /// The "QW" asset catalog image.
    static var QW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .QW)
#else
        .init()
#endif
    }

    /// The "R" asset catalog image.
    static var R: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .R)
#else
        .init()
#endif
    }

    /// The "TH" asset catalog image.
    static var TH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TH)
#else
        .init()
#endif
    }

    /// The "app_logo" asset catalog image.
    static var appLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appLogo)
#else
        .init()
#endif
    }

    /// The "barack_obama" asset catalog image.
    static var barackObama: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .barackObama)
#else
        .init()
#endif
    }

    /// The "brene_brown" asset catalog image.
    static var breneBrown: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .breneBrown)
#else
        .init()
#endif
    }

    /// The "elon_musk" asset catalog image.
    static var elonMusk: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elonMusk)
#else
        .init()
#endif
    }

    /// The "graph" asset catalog image.
    static var graph: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .graph)
#else
        .init()
#endif
    }

    /// The "jk_rowling" asset catalog image.
    static var jkRowling: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jkRowling)
#else
        .init()
#endif
    }

    /// The "launch_screen" asset catalog image.
    static var launchScreen: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchScreen)
#else
        .init()
#endif
    }

    /// The "malala_yousafzai" asset catalog image.
    static var malalaYousafzai: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .malalaYousafzai)
#else
        .init()
#endif
    }

    /// The "martin_luther_king" asset catalog image.
    static var martinLutherKing: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .martinLutherKing)
#else
        .init()
#endif
    }

    /// The "pitchGraph" asset catalog image.
    static var pitchGraph: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .pitchGraph)
#else
        .init()
#endif
    }

    /// The "roger_federer" asset catalog image.
    static var rogerFederer: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rogerFederer)
#else
        .init()
#endif
    }

    /// The "simon_sinek" asset catalog image.
    static var simonSinek: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .simonSinek)
#else
        .init()
#endif
    }

    /// The "steve_jobs" asset catalog image.
    static var steveJobs: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .steveJobs)
#else
        .init()
#endif
    }

    /// The "winston_churchill" asset catalog image.
    static var winstonChurchill: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .winstonChurchill)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "AE" asset catalog image.
    static var AE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AE)
#else
        .init()
#endif
    }

    /// The "BMP" asset catalog image.
    static var BMP: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BMP)
#else
        .init()
#endif
    }

    /// The "CDGKNSTXYZ" asset catalog image.
    static var CDGKNSTXYZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CDGKNSTXYZ)
#else
        .init()
#endif
    }

    /// The "FW" asset catalog image.
    static var FW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FW)
#else
        .init()
#endif
    }

    /// The "Highlights" asset catalog image.
    static var highlights: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .highlights)
#else
        .init()
#endif
    }

    /// The "L" asset catalog image.
    static var L: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .L)
#else
        .init()
#endif
    }

    /// The "O" asset catalog image.
    static var O: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .O)
#else
        .init()
#endif
    }

    /// The "QW" asset catalog image.
    static var QW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .QW)
#else
        .init()
#endif
    }

    /// The "R" asset catalog image.
    static var R: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .R)
#else
        .init()
#endif
    }

    /// The "TH" asset catalog image.
    static var TH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TH)
#else
        .init()
#endif
    }

    /// The "app_logo" asset catalog image.
    static var appLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .appLogo)
#else
        .init()
#endif
    }

    /// The "barack_obama" asset catalog image.
    static var barackObama: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .barackObama)
#else
        .init()
#endif
    }

    /// The "brene_brown" asset catalog image.
    static var breneBrown: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .breneBrown)
#else
        .init()
#endif
    }

    /// The "elon_musk" asset catalog image.
    static var elonMusk: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elonMusk)
#else
        .init()
#endif
    }

    /// The "graph" asset catalog image.
    static var graph: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .graph)
#else
        .init()
#endif
    }

    /// The "jk_rowling" asset catalog image.
    static var jkRowling: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jkRowling)
#else
        .init()
#endif
    }

    /// The "launch_screen" asset catalog image.
    static var launchScreen: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchScreen)
#else
        .init()
#endif
    }

    /// The "malala_yousafzai" asset catalog image.
    static var malalaYousafzai: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .malalaYousafzai)
#else
        .init()
#endif
    }

    /// The "martin_luther_king" asset catalog image.
    static var martinLutherKing: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .martinLutherKing)
#else
        .init()
#endif
    }

    /// The "pitchGraph" asset catalog image.
    static var pitchGraph: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .pitchGraph)
#else
        .init()
#endif
    }

    /// The "roger_federer" asset catalog image.
    static var rogerFederer: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rogerFederer)
#else
        .init()
#endif
    }

    /// The "simon_sinek" asset catalog image.
    static var simonSinek: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .simonSinek)
#else
        .init()
#endif
    }

    /// The "steve_jobs" asset catalog image.
    static var steveJobs: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .steveJobs)
#else
        .init()
#endif
    }

    /// The "winston_churchill" asset catalog image.
    static var winstonChurchill: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .winstonChurchill)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

