//
//  ViewController.swift
//  IDCardKeyBoardDemo
//
//  Created by fashion on 2018/12/15.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let id_cardTextField = DXTextField.init(frame: CGRect.init(x: 20, y: 50, width: 200, height: 40))
        id_cardTextField.borderStyle = .roundedRect
        id_cardTextField.placeholder = "code:请输入身份证号码"
        view.addSubview(id_cardTextField)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

