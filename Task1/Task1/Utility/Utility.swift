//
//  Utility.swift
//  Task1
//
//  Created by Bhanuja Tirumareddy on 17/06/20.
//  Copyright © 2020 Bhanuja Tirumareddy. All rights reserved.
//

import Foundation
import UIKit
class Utility {
    static let Shared = Utility()
    //MARK: - Alerts
    func showSimpleAlert(OnViewController vc: UIViewController?, Message message: String) {
        //Create alertController object with specific message
        let alertController = UIAlertController(title: AppConstants.Constants.appDisplayName, message: message, preferredStyle: .alert)
        //Add OK button to alert and dismiss it on action
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        //Show alert to user
        if let VC = vc {
            VC.present(alertController, animated: true, completion: nil)
        }
    }
    // MARK:-  ActivityIndicator
    func showActivityIndicatory(uiView: UIView?) -> UIView {
        if let view = uiView {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.center = view.center
        actInd.hidesWhenStopped = true
        actInd.style =
            UIActivityIndicatorView.Style.large
        actInd.stopAnimating()
        return actInd
    }
        return UIView()
    }
    
}
