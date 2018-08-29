//
//  CustomButton.swift
//  KS Mechanic
//
//  Created by Brian Alvarez on 8/24/18.
//  Copyright © 2018 Kryptic Studios. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButtons: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    func setCornerRadius(deg: CGFloat) {
        self.layer.cornerRadius = deg
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable override var backgroundColor: UIColor? {
        didSet {
            self.layer.backgroundColor = backgroundColor?.cgColor
        }
    }
    
}
