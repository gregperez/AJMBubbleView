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
    var eraseCompletion : ((Bool) -> Void)?
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
    
    lazy var eraseZone : UIView = {
        return UIView(frame: CGRect.zero)
    }()
    
    var eraseBottomConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Frame \(ajmView.frame)")
        view = ajmView
        ajmView.layer.cornerRadius = view.frame.width / 2
        ajmBadge.layer.cornerRadius = ajmBadge.frame.width / 2
        
        guard let aView = delegate?.sourceView(for: self) else { return }
       
        aView.addSubview(eraseZone)
        eraseZone.translatesAutoresizingMaskIntoConstraints = false
        eraseZone.backgroundColor = UIColor.red
        eraseZone.widthAnchor.constraint(equalToConstant: 100).isActive = true
        eraseZone.heightAnchor.constraint(equalToConstant: 100).isActive = true
        eraseBottomConstraint = eraseZone.bottomAnchor.constraint(equalTo: aView.safeAreaLayoutGuide.bottomAnchor, constant: 25)
        eraseBottomConstraint.isActive = true
        eraseZone.centerXAnchor.constraint(equalTo: aView.centerXAnchor, constant: 0).isActive = true
    }

    func place(on anchorPoint : AnchorPoint) {
        
        guard let aView = delegate?.sourceView(for: self) else { return }

        deactivateConstraintsIfNeeded()
        
        let destinyPoint = calculateDestiny(from: anchorPoint.rawValue)
        centerXConstraint = ajmView.centerXAnchor.constraint(equalTo: aView.safeAreaLayoutGuide.centerXAnchor)
        centerYConstraint = ajmView.centerYAnchor.constraint(equalTo: aView.safeAreaLayoutGuide.centerYAnchor)
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
        
        guard let aView = delegate?.sourceView(for: self) else { return }
        deactivateConstraintsIfNeeded()
        
        // Drag view
        let translation = sender.translation(in: aView)
        ajmView.center = CGPoint(x: ajmView.center.x + translation.x, y: ajmView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: aView)
        
        switch sender.state {
            
            
            case .ended:
                
                let point = ajmView.center
                let isInEraseZone = eraseZone.frame.contains(point)
                if isInEraseZone {
                    eraseZone.backgroundColor = UIColor.brown
                    print("ESTA EN ERASE ZONE")
                    widthConstraint.constant = 1
                    eraseBottomConstraint.constant = 100
                    ajmView.centerXAnchor.constraint(equalTo: aView.centerXAnchor, constant: 0).isActive = true
                    ajmView.bottomAnchor.constraint(equalTo: aView.bottomAnchor, constant: 100).isActive = true
 
                    UIView.animate(withDuration: 0.3, animations: {
                        aView.layoutIfNeeded()
                    }, completion: { [weak self](status) in
                        if status {
                            self?.eraseZone.removeFromSuperview()
                            self?.eraseCompletion?(true)
                        }
                       
                    })
                    return
                } else {
                    eraseZone.backgroundColor = UIColor.red
                }
                
                let destinyPoint = calculateDestiny(from: point)
                
                centerXConstraint = ajmView.centerXAnchor.constraint(equalTo: aView.safeAreaLayoutGuide.centerXAnchor)
                centerYConstraint = ajmView.centerYAnchor.constraint(equalTo: aView.safeAreaLayoutGuide.centerYAnchor)
                centerXConstraint.constant = destinyPoint.x
                centerYConstraint.constant = destinyPoint.y
                NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
                
                UIView.animate(withDuration: 0.3, animations: {
                    aView.layoutIfNeeded()
                })
            
            break
            
            default:
                let point = ajmView.center
                let isInEraseZone = eraseZone.frame.contains(point)
                if isInEraseZone {
                    eraseZone.backgroundColor = UIColor.brown
                    print("ESTA EN ERASE ZONE")
                } else {
                    eraseZone.backgroundColor = UIColor.red
                }
                
                
            break
        }
        
    }
    
    func calculateDestiny(from aPoint: CGPoint) -> CGPoint {
       
        let point = CGPoint(x: abs(aPoint.x), y: abs(aPoint.y))

        guard let aView = delegate?.sourceView(for: self) else {
            return CGPoint.zero
            
        }
        
        let deltaX = aView.bounds.width / 6
        let deltaY = aView.bounds.height / 5
        
        // Quadrant 1 (top left)
        if point.x >= 0 && point.x < aView.bounds.width / 2 &&
           point.y >= 0 && point.y < aView.bounds.height / 2 {
            return CGPoint(x: -2 * deltaX, y: -2 * deltaY)
            
        // Quadrant 2 (top right)
        } else if point.x >= aView.bounds.width / 2 &&
            point.y <= aView.bounds.height / 2 {
            return CGPoint(x: 2 * deltaX, y: -2 * deltaY)

        // Quadrant 3 (bottom left)
        } else if point.x >= 0 && point.x < aView.bounds.width / 2 &&
            point.y >= aView.bounds.height / 2 {
            return CGPoint(x: -2 * deltaX, y: 2 * deltaY)
            
        // Quadrant 4 (bottom right)
        } else if point.x >= aView.bounds.width / 2 &&
            point.y >= aView.bounds.height / 2 {
            return CGPoint(x: 2 * deltaX, y: 2 * deltaY)
        }
        return CGPoint.zero
    }
    

    
}

