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
        super.updateConstraints()
        print("updateConstraints")
    }

}
