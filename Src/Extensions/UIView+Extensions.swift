//
//  UIView+Extensions.swift
//  GardenController
//
//  Created by Tord Wessman on 13/01/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func xibSetup(nibName: String? = nil) {
        
        let name = nibName ?? String(describing: type(of: self))
        
        let view: UIView = loadViewFromNib(nibName: name)
        view.frame = bounds
        
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        addSubview(view)
    }
    
    public func loadViewFromNib(nibName: String) -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
}
