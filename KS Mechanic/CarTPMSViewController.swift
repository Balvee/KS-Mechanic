//
//  CarTPMSViewController.swift
//  KS Mechanic
//
//  Created by Brian Alvarez on 8/24/18.
//  Copyright © 2018 Kryptic Studios. All rights reserved.
//

import UIKit
import CoreBluetooth
import UICircularProgressRing

class CarTPMSViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    @IBOutlet weak var rrProgressRing: UICircularProgressRing!
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rrProgressRing.maxValue = 50
        rrProgressRing.innerRingColor = UIColor.green
        
        rrProgressRing.startProgress(to: 32, duration: 2.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
