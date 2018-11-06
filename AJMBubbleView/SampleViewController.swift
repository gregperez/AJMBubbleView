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
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bubbleVC = storyboard.instantiateViewController(withIdentifier: "BubbleVC") as! AJMBubbleViewController
        bubbleVC.delegate = self
        addChild(bubbleVC)
        view.addSubview(bubbleVC.view)
        bubbleVC.didMove(toParent: self)
        bubbleVC.place(on: .bottomRight)
    }

    @IBAction func updateLabel(_ sender: Any) {
        titleLabel.text = "\(counter)"
        counter = counter + 1
    }
    
}

extension SampleViewController : AJMBubbleViewControllerDelegate {
    
    func sourceView(for bubbleController: AJMBubbleViewController) -> UIView? {
        return view!
    }
}
