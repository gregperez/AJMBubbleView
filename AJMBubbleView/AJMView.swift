//
//  AJMView.swift
//  ConstraintSample
//
//  Created by Morales, Angel (MX - Mexico) on 04/11/18.
//  Copyright © 2018 TheKairuz. All rights reserved.
//

import UIKit

class AJMView: UIView {
   
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        
    }
    
    override func updateConstraints() {
        if customConstraints == nil {
            let top = iconImageView.topAnchor.constraint(equalTo: topAnchor)
            let bottom = iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            let leading = iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor)
            let trailing = iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
            
            let badgeWidth = ajmBadge.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35)
            let badgeHeight = ajmBadge.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35)
            let badgeTop = ajmBadge.topAnchor.constraint(equalTo: topAnchor, constant: -6)
            let badgeTrailing = ajmBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 5)
            
            ajmBadge.addSubview(notificationLabel)
            let centerXLabel = notificationLabel.centerXAnchor.constraint(equalTo: ajmBadge.centerXAnchor)
            let centerYLabel = notificationLabel.centerYAnchor.constraint(equalTo: ajmBadge.centerYAnchor)
            
            customConstraints = [top, bottom, leading, trailing, badgeWidth, badgeHeight, badgeTop, badgeTrailing, centerXLabel, centerYLabel]

            NSLayoutConstraint.activate(customConstraints)
        }
        super.updateConstraints()
        print("updateConstraints")
    }

}
