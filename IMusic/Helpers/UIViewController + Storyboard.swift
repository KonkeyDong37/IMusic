//
//  UIViewController + Storyboard.swift
//  IMusic
//
//  Created by Андрей on 03.12.2020.
//

import UIKit

extension UIViewController {
    
    class func loadFromStoryboard<T: UIViewController>() -> T {
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        
        if let viewController = storyboard.instantiateInitialViewController() as? T {
            return viewController
        } else {
            fatalError("Error no initial view controller in \(name) storyboard")
        }
    }
}
