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
    func ajmBubbleViewController(sender : AJMBubbleViewController, didDeleteView flag : Bool)
    func numberOfNotifications(sender : AJMBubbleViewController) -> Int?
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
   
    private var eraseBottomConstraint : NSLayoutConstraint!

    private var bubbleWidthConstraint : NSLayoutConstraint! {
        didSet {
            bubbleWidthConstraint.identifier = "Bubble width constraint"
        }
    }
    
    private var centerXConstraint: NSLayoutConstraint! {
        didSet {
            // debugging purposes
            centerXConstraint.identifier = "Bubble center X Constraint"
        }
    }
    
    private var centerYConstraint: NSLayoutConstraint! {
        didSet {
            centerYConstraint.identifier = "Bubble center Y Constraint"
        }
    }
    
    private lazy var ajmView : AJMView = {
        let view = AJMView()
        return view
    }()
    
    private lazy var eraseZone : UIView = {
        return UIView(frame: CGRect.zero)
    }()
    
    private lazy var trashImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trash-can-close")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var trashIsOpen = false {
        didSet {
            trashImageView.image = trashIsOpen ? UIImage(named: "trash-can-open") : UIImage(named: "trash-can-close")
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        view.backgroundColor = UIColor.blue
        view.addSubview(ajmView)
        ajmView.prepare(image: UIImage(named: "tomHardy")!)
        ajmView.translatesAutoresizingMaskIntoConstraints = false
        
        centerXConstraint = ajmView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        centerXConstraint.isActive = true
        centerYConstraint = ajmView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerYConstraint.isActive = true
        view = ajmView
        bubbleWidthConstraint = view.widthAnchor.constraint(equalToConstant: 0)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragging(_:)))
        ajmView.addGestureRecognizer(panGesture)

        guard let aView = delegate?.sourceView(for: self) else { return }
        
        aView.addSubview(eraseZone)
        eraseZone.translatesAutoresizingMaskIntoConstraints = false
        eraseZone.backgroundColor = UIColor.red
        eraseZone.widthAnchor.constraint(equalToConstant: 100).isActive = true
        eraseZone.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        eraseZone.addSubview(trashImageView)
        trashImageView.centerXAnchor.constraint(equalTo: eraseZone.centerXAnchor).isActive = true
        trashImageView.topAnchor.constraint(equalTo: eraseZone.topAnchor, constant: 5).isActive = true
        trashImageView.widthAnchor.constraint(equalTo: eraseZone.widthAnchor, multiplier: 0.5).isActive = true
        trashImageView.heightAnchor.constraint(equalTo: eraseZone.heightAnchor, multiplier: 0.5).isActive = true

        eraseBottomConstraint = eraseZone.bottomAnchor.constraint(equalTo: aView.safeAreaLayoutGuide.bottomAnchor, constant: 25)
        eraseBottomConstraint.isActive = true
        eraseZone.centerXAnchor.constraint(equalTo: aView.centerXAnchor, constant: 0).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }

    func place(on anchorPoint : AnchorPoint) {
        deactivateConstraintsIfNeeded()
        stickBubbleWith(position: anchorPoint.rawValue, animated: false)
    }
    
    func reloadBubble() {
        guard let numberOfNotifications = delegate?.numberOfNotifications(sender: self) else {
            return
        }
        ajmView.updateBadge(numberOfNotifications)
        
    }
    
    private func deactivateConstraintsIfNeeded() {
        if centerXConstraint != nil {
            centerXConstraint.isActive = false
            centerYConstraint.isActive = false
        }
    }
    
    private func deleteBubble() {
        guard let aView = delegate?.sourceView(for: self) else { return }

        eraseZone.backgroundColor = UIColor.brown
        bubbleWidthConstraint.constant = 1
        eraseBottomConstraint.constant = 200
        ajmView.centerXAnchor.constraint(equalTo: aView.centerXAnchor, constant: 0).isActive = true
        ajmView.bottomAnchor.constraint(equalTo: aView.bottomAnchor, constant: 100).isActive = true
        
        UIView.animate(withDuration: 0.3, animations: {
            aView.layoutIfNeeded()
        }, completion: { [weak self](status) in
            guard let strongSelf = self else { return }
            strongSelf.eraseZone.removeFromSuperview()
            strongSelf.delegate?.ajmBubbleViewController(sender: strongSelf, didDeleteView: true)
        })
        
    }
    
    private func stickBubbleWith(position : CGPoint, animated : Bool = true) {
        
        guard let aView = delegate?.sourceView(for: self) else { return }

        var destinyPoint : CGPoint = CGPoint.zero
        if self.traitCollection.userInterfaceIdiom == .pad {
            destinyPoint = calculateDestiny(from: position, factor : 2.5)
        } else {
            destinyPoint = calculateDestiny(from: position)
        }
        
        centerXConstraint = ajmView.centerXAnchor.constraint(equalTo: aView.safeAreaLayoutGuide.centerXAnchor)
        centerYConstraint = ajmView.centerYAnchor.constraint(equalTo: aView.safeAreaLayoutGuide.centerYAnchor)
        centerXConstraint.constant = destinyPoint.x
        centerYConstraint.constant = destinyPoint.y
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                aView.layoutIfNeeded()
            })
        }
        
    }
    
    @objc func dragging(_ sender: UIPanGestureRecognizer) {
        
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
                    trashIsOpen = true
                    deleteBubble()
                    return
                } else {
                    trashIsOpen = false
                }
                stickBubbleWith(position: point)
                
            break
            
            default:
                let point = ajmView.center
                let isInEraseZone = eraseZone.frame.contains(point)
                if isInEraseZone {
                    trashIsOpen = true
                } else {
                    trashIsOpen = false
                }
                
                
            break
        }
        
    }
    
    private func calculateDestiny(from aPoint: CGPoint, factor : CGFloat = 2) -> CGPoint {
        let point = CGPoint(x: abs(aPoint.x), y: abs(aPoint.y))

        guard let aView = delegate?.sourceView(for: self) else {
            return CGPoint.zero
            
        }
        
        let deltaX = aView.bounds.width / 6
        let deltaY = aView.bounds.height / 5
        
        // Quadrant 1 (top left)
        if point.x >= 0 && point.x < aView.bounds.width / 2 &&
           point.y >= 0 && point.y < aView.bounds.height / 2 {
            return CGPoint(x: -factor * deltaX, y: -2 * deltaY)
            
        // Quadrant 2 (top right)
        } else if point.x >= aView.bounds.width / 2 &&
            point.y <= aView.bounds.height / 2 {
            return CGPoint(x: factor * deltaX, y: -2 * deltaY)

        // Quadrant 3 (bottom left)
        } else if point.x >= 0 && point.x < aView.bounds.width / 2 &&
            point.y >= aView.bounds.height / 2 {
            return CGPoint(x: -factor * deltaX, y: 2 * deltaY)
            
        // Quadrant 4 (bottom right)
        } else if point.x >= aView.bounds.width / 2 &&
            point.y >= aView.bounds.height / 2 {
            return CGPoint(x: factor * deltaX, y: 2 * deltaY)
        }
        return CGPoint.zero
    }
    
}

