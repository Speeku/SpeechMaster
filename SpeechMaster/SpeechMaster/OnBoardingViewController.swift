//
//  OnBoardingViewController.swift
//  SpeechMaster
//
//  Created by Abuzar Siddiqui on 21/01/25.
//

import UIKit

class OnBoardingViewController: UIViewController, CustomPageControlDelegate {
    func pageControl(_ pageControl: CustomPageControl, didSelectPageAt index: Int) {
    // Handle the page change
    currentIndex = index
    updateUI()
}
    
    
   
    @IBOutlet weak var skipButton: UIBarButtonItem!
    @IBOutlet weak var displayImagesView: UIImageView!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    let pageControl = CustomPageControl()
    var currentIndex = 0
    let imageData = ImageData.shared
    func updateUI() {
        if currentIndex == 0 {
                    removeBackButton()
                } else {
                    addBackButton()
                }
        let currentData = ImageData.shared[currentIndex]
        pageControl.currentPage = currentIndex
        if let image = UIImage(named: currentData.imageName) {
                // Animate the image change with crossfade
            UIView.transition(with: displayImagesView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.displayImagesView.image = image
                }, completion: nil)
            } else {
                print("Image with name \(currentData.imageName) not found in assets.")
            }

        headingLabel.text = currentData.headingLabel
        contentLabel.text = currentData.contentLabel
        if currentIndex == imageData.count - 1 {
            skipButton.isEnabled = false // Hides the Skip button
            skipButton.tintColor = UIColor.clear // Makes it invisible visually
            nextButton.setTitle("Get Started", for: .normal) // Change button text
        } else {
            skipButton.isEnabled = true
            skipButton.tintColor = nil // Restores visibility
            nextButton.setTitle("Next", for: .normal) // Default button text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeBackButton()
        pageControl.numberOfPages = imageData.count
        pageControl.currentPage = 0
        // Configure the custom page control
        
               pageControl.dotColor = .lightGray
        pageControl.selectedDotColor = .black
               pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.delegate = self
               view.addSubview(pageControl)

               // Set up constraints
               NSLayoutConstraint.activate([
                pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150),
                   pageControl.heightAnchor.constraint(equalToConstant: 20),
                   pageControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
               ])
        updateUI()
        // Do any additional setup after loading the view.
    }
    func removeBackButton() {
            navigationItem.leftBarButtonItem = nil // Remove the back button
        }
    func addBackButton() {
        // Create the Chevron Left icon using system image
        print("Back button tapped")
                let chevronIcon = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
                
                // Create the custom view containing both chevron and title
                let backButtonView = UIStackView()
                backButtonView.axis = .horizontal
                backButtonView.spacing = 8 // Space between chevron and title
                backButtonView.alignment = .center
                
                // Create the chevron image view
                let chevronImageView = UIImageView(image: chevronIcon)
                chevronImageView.tintColor = .systemBlue // Optional: Customize the color of the chevron
        // Increase the size of the chevron
            let scale: CGFloat = 1.5 // Adjust this value to scale the chevron size
            chevronImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                // Create the label for the back title
                let backLabel = UILabel()
                backLabel.text = "Back"
                backLabel.textColor = .systemBlue // Optional: Customize the text color
                
                // Add chevron and title to the stack view
                backButtonView.addArrangedSubview(chevronImageView)
                backButtonView.addArrangedSubview(backLabel)
                
                // Create a UIBarButtonItem from the custom view
                let backButton = UIBarButtonItem(customView: backButtonView)
        backButton.target = self
                backButton.action = #selector(backButtonTapped)
        // Alternatively, add a gesture recognizer if the action still doesn't trigger
            backButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonTapped)))
                // Set the custom back button
                navigationItem.leftBarButtonItem = backButton
        }
    func updatePageControl(to page: Int) {
            pageControl.currentPage = page
        }
    
    @objc func backButtonTapped() {
            if currentIndex > 0 {
                currentIndex -= 1
                updateUI()
            }
        }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        //update page control
        
        //handle logic
        if currentIndex == imageData.count - 1 {
            // Perform segue to navigate to the next view controller
            performSegue(withIdentifier: "goToLoginScreen", sender: self)
        } else {
            // Navigate to the next screen in the current flow
            navigate(toNext: true)
        }
        
        
        
    }
    func navigate(toNext: Bool) {
        if toNext {
            currentIndex = min(currentIndex + 1, imageData.count - 1)
        } else {
            currentIndex = max(currentIndex - 1, 0)
        }
        updateUI()
    }
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    
}
