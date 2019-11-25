//
//  Alerts.swift
//  YokeShin
//
//  Created by admin on 25/11/2019.
//  Copyright © 2019 aung. All rights reserved.
//

import Foundation
import UIKit

class Alerts {
    static func showAlert (VC : UIViewController, title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        VC.present(alert, animated: true, completion: nil)
    }
}
