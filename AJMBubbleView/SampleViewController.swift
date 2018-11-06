//
//  SampleViewController.swift
//  AJMBubbleView
//
//  Created by Morales, Angel (MX - Mexico) on 05/11/18.
//  Copyright © 2018 TheKairuz. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: NSLayoutConstraint!
    var counter = 0
    var bubbleVC : AJMBubbleViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()  
    }

    @IBAction func updateLabel(_ sender: Any) {
        titleLabel.text = "\(counter)"
        counter = counter + 1
       
        guard bubbleVC == nil else { return }
        let bubble = AJMBubbleViewController()
        bubble.delegate = self
        let bubbleView = bubble.view!
        
        // Define the size of the bubble
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        bubbleView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        addChild(bubble)
        view.addSubview(bubbleView)
        bubble.didMove(toParent: self)
        bubble.place(on: .bottomRight)
        self.bubbleVC = bubble

    }
    
}

extension SampleViewController : AJMBubbleViewControllerDelegate {
    
    func sourceView(for bubbleController: AJMBubbleViewController) -> UIView? {
        return view!
    }
    
    func ajmBubbleViewController(sender: AJMBubbleViewController, didDeleteView flag: Bool) {
        self.bubbleVC?.willMove(toParent: nil)
        self.bubbleVC?.view.removeFromSuperview()
        self.bubbleVC?.removeFromParent()
        self.bubbleVC = nil
    }
}
