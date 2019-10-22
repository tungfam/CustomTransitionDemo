//
//  SecondViewController.swift
//  CustomTransitionDemo
//
//  Created by Tung on 13.10.19.
//  Copyright © 2019 Tung. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet private(set) var locationImageView: UIImageView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }

}
