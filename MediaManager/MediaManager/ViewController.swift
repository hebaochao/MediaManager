//
//  ViewController.swift
//  MediaManager
//
//  Created by ChinaTeam on 16/8/21.
//  Copyright © 2016年 Alex. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func gotoChooseImageVC(sender: AnyObject) {
        
        self.presentViewController(UINavigationController(rootViewController: NTAssetViewController()), animated: true, completion: nil)
        
    }
}

