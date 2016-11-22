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
    
    @IBAction func undoTapped(_ sender: Any) {
    }
    
    @IBAction func redoTapped(_ sender: Any) {
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        // image to share
        guard let image = self.captureView() else { return }
        
        // set up activity view controller
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    func captureView() -> UIImage? {
    
        let rect = self.containerView.bounds
        var img: UIImage? = nil
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.containerView.layer.render(in: context)
            img = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return img
    }
    

}

