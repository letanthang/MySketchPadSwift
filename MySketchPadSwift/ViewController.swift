//
//  ViewController.swift
//  MySketchPadSwift
//
//  Created by Le Tan Thang on 11/11/16.
//  Copyright © 2016 Le Tan Thang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var padView: FinalAlgView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

