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
        guard let image = self.captureView() else { return }
        
        /*
        // 1st way : UIImageWriteToSavedPhotosAlbum
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageDone(_:didFinishSavingWithError:contextInfo:)), nil)
        */
        // 2nd way : share image by UIActivityViewController
        let imageToShare = [image]
        let avc = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        avc.popoverPresentationController?.sourceView = self.view // fix for ipad crash
        avc.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToTwitter, UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.print]
        
        present(avc, animated: true, completion: nil)
        
        
        
    }
    
    func imageDone(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("There was an error: \(error.localizedDescription)")
            let ac = UIAlertController(title: "Save error", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Your art is save successfully!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            
        }
    }
    
    func temp() {
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

