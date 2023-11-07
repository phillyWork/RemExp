//
//  Extensions.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit

extension UIView {
    
    //place objects wherever we want on screen
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        //UI programmatically: should set storyboard to false
        translatesAutoresizingMaskIntoConstraints = false
        
        //anchor values are optional: most of time, need 2 anchors (X and Y)
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            //direction of padding: paddingBottom should be negative
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            //direction of padding: paddingRight should be negative
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        //xcode sets height for label and button when we don't give input to height
        
    }
    
}
