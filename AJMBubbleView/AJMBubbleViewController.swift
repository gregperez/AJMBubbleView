//
//  ViewController.swift
//  ConstraintSample
//
//  Created by Morales, Angel (MX - Mexico) on 04/11/18.
//  Copyright © 2018 TheKairuz. All rights reserved.
//

import UIKit

protocol AJMBubbleViewControllerDelegate : class {
    func sourceView(for bubbleController :  AJMBubbleViewController) -> UIView?
}

enum AnchorPoint {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    var rawValue : CGPoint {
        switch self {
            case .topLeft:
                return CGPoint(x: CGFloat.leastNormalMagnitude, y: CGFloat.leastNormalMagnitude)
            case .topRight:
                return CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.leastNormalMagnitude)
            case .bottomLeft:
                return CGPoint(x: CGFloat.leastNormalMagnitude, y: CGFloat.greatestFiniteMagnitude)
            case .bottomRight:
                return CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
        }
    }
}

class AJMBubbleViewController: UIViewController {

    weak var delegate : AJMBubbleViewControllerDelegate?
    @IBOutlet weak var ajmBadge: UIView!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint! {
        didSet {
            // debugging purposes
            widthConstraint.identifier = "AJM Width Constraint"
        }
    }
    
    var originalConstraint : CGFloat = 0
    
    @IBOutlet weak var centerXConstraint: NSLayoutConstraint! {
        didSet {
            // debugging purposes
            centerXConstraint.identifier = "AJM Center X Constraint"

        }
    }
    
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint! {
        didSet {
            centerYConstraint.identifier = "AJM Center Y Constraint"

        }
    }
    
    @IBOutlet weak var ajmView: AJMView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalConstraint = widthConstraint.constant
        print("Frame \(ajmView.frame)")
       
        placeTopLeft()
    }

    func placeTopLeft() {
        
        deactivateConstraintsIfNeeded()
        
        let destinyPoint = calculateDestiny(from: CGPoint(x: 0, y: 0))
        centerXConstraint = ajmView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        centerYConstraint = ajmView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        centerXConstraint.constant = destinyPoint.x
        centerYConstraint.constant = destinyPoint.y
        
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
    }
    
    func deactivateConstraintsIfNeeded() {
        if centerXConstraint != nil {
            centerXConstraint.isActive = false
            centerYConstraint.isActive = false
        }
    }
    
    @IBAction func dragging(_ sender: UIPanGestureRecognizer) {
        
        deactivateConstraintsIfNeeded()
        
        // Drag view
        let translation = sender.translation(in: self.view)
        ajmView.center = CGPoint(x: ajmView.center.x + translation.x, y: ajmView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        switch sender.state {
            
        case .ended:
            print("Los trait collection son:  \(self.traitCollection.horizontalSizeClass.rawValue), \(self.traitCollection.verticalSizeClass.rawValue)")
            print("Las coordenadas son:  \(ajmView.center)")
            
            let point = ajmView.center
            let destinyPoint = calculateDestiny(from: point)
            
            centerXConstraint = ajmView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            centerYConstraint = ajmView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            centerXConstraint.constant = destinyPoint.x
            centerYConstraint.constant = destinyPoint.y
            NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
            break
            
        default:
            break
        }
        
    }
    
    func calculateDestiny(from point: CGPoint) -> CGPoint {
       
        let deltaX = self.view.bounds.width / 6
        let deltaY = self.view.bounds.height / 5
        
        // Quadrant 1 (top left)
        if point.x >= 0 && point.x < self.view.bounds.width / 2 &&
           point.y >= 0 && point.y < self.view.bounds.height / 2 {
            return CGPoint(x: -2 * deltaX, y: -2 * deltaY)
            
        // Quadrant 2 (top right)
        } else if point.x >= self.view.bounds.width / 2 &&
            point.y <= self.view.bounds.height / 2 {
            return CGPoint(x: 2 * deltaX, y: -2 * deltaY)

        // Quadrant 3 (bottom left)
        } else if point.x >= 0 && point.x < self.view.bounds.width / 2 &&
            point.y >= self.view.bounds.height / 2 {
            return CGPoint(x: -2 * deltaX, y: 2 * deltaY)
            
        // Quadrant 4 (bottom right)
        } else if point.x >= self.view.bounds.width / 2 &&
            point.y >= self.view.bounds.height / 2 {
            return CGPoint(x: 2 * deltaX, y: 2 * deltaY)
        }
        return CGPoint.zero
    }
    
    @IBAction func growView(_ sender: Any) {
        print("grow animate width constraint Button Tapped")
        self.widthConstraint.constant = self.widthConstraint.constant * 1.3
       
        UIView.animate(withDuration: 2.0, animations: {
             self.view.layoutIfNeeded()
        }, completion: { (status) in
            if status {
                print("Terminando la animación ")
                self.ajmView.setNeedsDisplay()
            }
        })
    }
    
    @IBAction func growNoAnimate(_ sender: Any) {
        print("Grow no animate Button Tapped")
        widthConstraint.constant = originalConstraint
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
        print("Frame \(ajmView.frame)")

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
        print("Frame \(ajmView.frame)")

    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        print("updateViewConstraints")
        print("Frame \(ajmView.frame)")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        print("Frame \(ajmView.frame)")

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        print("Frame \(ajmView.frame)")

    }
}

