//
//  AJMView.swift
//  ConstraintSample
//
//  Created by Morales, Angel (MX - Mexico) on 04/11/18.
//  Copyright © 2018 TheKairuz. All rights reserved.
//

import UIKit

class AJMView: UIView {

    var titleLabel : UILabel!
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("Draw Rect")
        if bounds.width >= 200 && titleLabel == nil {
            titleLabel = UILabel()
            titleLabel.text = "Hola"
            addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
        } else {
            if titleLabel != nil {
                titleLabel.removeFromSuperview()
                titleLabel = nil
            }
        }
        
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        print("updateConstraints")
    }

}
