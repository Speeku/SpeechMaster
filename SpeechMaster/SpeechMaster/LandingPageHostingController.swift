//
//  LandingPageHostingControllerViewController.swift
//  SpeechMaster
//
//  Created by Kushagra Kulshrestha on 22/01/25.
//

import UIKit
import SwiftUI

class LandingPageHostingController: UIHostingController<LandingPageView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LandingPageView())
    }
}

//class LandingPageHostingController: UIHostingController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//}
