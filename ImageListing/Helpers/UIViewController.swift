//
//  UIViewController.swift
//  Helpers
//
//  Created by Iustin Bulimar on 02/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit
import Toast_Swift

extension UIViewController {
    
    static func instance(storyboardName: String? = nil, isInitial: Bool = false) -> Self {
        return genericInstance(storyboardName: storyboardName, isInitial: isInitial)
    }
    
    private static func genericInstance<ViewController: UIViewController>(storyboardName: String?, isInitial: Bool) -> ViewController {
        let storyboard = UIStoryboard(name: storyboardName ?? "\(ViewController.self)", bundle: Bundle(for: ViewController.self))
        
        switch isInitial {
        case true:
            guard let viewController = storyboard.instantiateInitialViewController() as? ViewController else {
                fatalError("ViewController is not set as initial or is not of the expected class \(ViewController.self).")
            }
            return viewController
            
        case false:
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "\(ViewController.self)") as? ViewController else {
                fatalError("ViewController has no identifier or is not of the expected class \(ViewController.self).")
            }
            return viewController
        }
    }
    
    func showError(message: String = "Try again later!") {
        view.makeToast(message, position: .top)
    }
    
}

