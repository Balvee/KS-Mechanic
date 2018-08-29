//
//  MotoTPMSViewController.swift
//  KS Mechanic
//
//  Created by Brian Alvarez on 8/24/18.
//  Copyright © 2018 Kryptic Studios. All rights reserved.
//

import UIKit
import CoreBluetooth
import UICircularProgressRing

// Core Bluetooth service IDs
//let BLE_TPMS_Service_CBUUID = CBUUID(string: "0xFBB0")

// Core Bluetooth characteristic IDs
//let BLE_TPMS_Characteristic_CBUUID = CBUUID(string: "00000A")

class MotoTPMSViewController: UIViewController{
    /*, CBCentralManagerDelegate, CBPeripheralDelegate 
    // UI outlets / member variables
    @IBOutlet weak var frontTPMS: UICircularProgressRing!
    @IBOutlet weak var frontBattery: UIProgressView!
    @IBOutlet weak var frontTemp: UILabel!
    @IBOutlet weak var rearTPMS: UICircularProgressRing!
    @IBOutlet weak var rearBattery: UIProgressView!
    @IBOutlet weak var rearTemp: UILabel!
    
    var centralManager: CBCentralManager?
    var peripheralTPMS: CBPeripheral?
    var pressureHEX: String?
    
    @IBOutlet weak var connectingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionStatusView: UIView!
    @IBOutlet weak var sensorLocationTextField: UITextField!
    @IBOutlet weak var bluetoothOffLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scanning while not connected
        connectingActivityIndicator.backgroundColor = UIColor.white
        connectingActivityIndicator.startAnimating()
        connectionStatusView.backgroundColor = UIColor.red
        frontTemp.text = "----"
        sensorLocationTextField.text = "----"
        // JIC Bluetooth is turned off
        bluetoothOffLabel.alpha = 0.0
        
        // Create a concurrent background queue for the central
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.krypticstudios.centralQueueName", attributes: .concurrent)
        // Create a central to scan for, connect to,
        // manage, and collect data from peripherals
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        
        // read heart rate data from HKHealthStore
        // healthKitInterface.readHeartRateData()
        
        // read gender type from HKHealthStore
        // healthKitInterface.readGenderType()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CBCentralManagerDelegate methods
    
    // STEP 3.1: this method is called based on
    // the device's Bluetooth state; we can ONLY
    // scan for peripherals if Bluetooth is .poweredOn
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
            
        case .unknown:
            print("Bluetooth status is UNKNOWN")
            bluetoothOffLabel.alpha = 1.0
        case .resetting:
            print("Bluetooth status is RESETTING")
            bluetoothOffLabel.alpha = 1.0
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
            bluetoothOffLabel.alpha = 1.0
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
            bluetoothOffLabel.alpha = 1.0
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            bluetoothOffLabel.alpha = 1.0
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            
            DispatchQueue.main.async { () -> Void in
                self.bluetoothOffLabel.alpha = 0.0
                self.connectingActivityIndicator.startAnimating()
            }
            
            // STEP 3.2: scan for peripherals that we're interested in
            centralManager?.scanForPeripherals(withServices: [BLE_TPMS_Service_CBUUID])
            
        } // END switch
        
    } // END func centralManagerDidUpdateState
    
    // STEP 4.1: discover what peripheral devices OF INTEREST
    // are available for this app to connect to
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print(peripheral.name!)
        decodePeripheralState(peripheralState: peripheral.state)
        // STEP 4.2: MUST store a reference to the peripheral in
        // class instance variable
        peripheralTPMS = peripheral
        // STEP 4.3: since HeartRateMonitorViewController
        // adopts the CBPeripheralDelegate protocol,
        // the peripheralHeartRateMonitor must set its
        // delegate property to HeartRateMonitorViewController
        // (self)
        peripheralTPMS?.delegate = self
        
        // STEP 5: stop scanning to preserve battery life;
        // re-scan if disconnected
        centralManager?.stopScan()
        
        // STEP 6: connect to the discovered peripheral of interest
        centralManager?.connect(peripheralTPMS!)
        
    } // END func centralManager(... didDiscover peripheral
    
    // STEP 7: "Invoked when a connection is successfully created with a peripheral."
    // we can only move forwards when we know the connection
    // to the peripheral succeeded
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        DispatchQueue.main.async { () -> Void in
            
            self.frontTemp.text = peripheral.name!
            self.connectionStatusView.backgroundColor = UIColor.green
            self.sensorLocationTextField.text = "----"
            self.connectingActivityIndicator.stopAnimating()
            
        }
        
        // STEP 8: look for services of interest on peripheral
        peripheralTPMS?.discoverServices([BLE_TPMS_Service_CBUUID])
        
    } // END func centralManager(... didConnect peripheral
    
    // STEP 15: when a peripheral disconnects, take
    // use-case-appropriate action
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        // print("Disconnected!")
        
        DispatchQueue.main.async { () -> Void in
            
            self.frontTemp.text = "----"
            self.connectionStatusView.backgroundColor = UIColor.red
            self.sensorLocationTextField.text = "----"
            self.connectingActivityIndicator.startAnimating()
            
        }
        
        // STEP 16: in this use-case, start scanning
        // for the same peripheral or another, as long
        // as they're HRMs, to come back online
        centralManager?.scanForPeripherals(withServices: [BLE_TPMS_Service_CBUUID])
        
    } // END func centralManager(... didDisconnectPeripheral peripheral
    
    // MARK: - CBPeripheralDelegate methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            
            if service.uuid == BLE_TPMS_Service_CBUUID {
                
                print("Service: \(service)")
                
                // STEP 9: look for characteristics of interest
                // within services of interest
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
            
        }
        
    } // END func peripheral(... didDiscoverServices
    
    // STEP 10: confirm we've discovered characteristics
    // of interest within services of interest
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for characteristic in service.characteristics! {
            print(characteristic)
            
            if characteristic.uuid == BLE_TPMS_Characteristic_CBUUID {
                
                // STEP 11: subscribe to regular notifications
                // for characteristic of interest;
                // "When you enable notifications for the
                // characteristic’s value, the peripheral calls
                // ... peripheral(_:didUpdateValueFor:error:)
                //
                // Notify    Mandatory
                //
                peripheral.setNotifyValue(true, for: characteristic)
                
            }
            
        } // END for
        
    } // END func peripheral(... didDiscoverCharacteristicsFor service
    
    // STEP 12: we're notified whenever a characteristic
    // value updates regularly or posts once; read and
    // decipher the characteristic value(s) that we've
    // subscribed to
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic.uuid == BLE_TPMS_Characteristic_CBUUID {
            
            // STEP 13: we generally have to decode BLE
            // data into human readable format
            //let pressure = getPSI(using: "0x0003f8")
            
            DispatchQueue.main.async { () -> Void in
                
                UIView.animate(withDuration: 1.0, animations: {
                  //  self.beatsPerMinuteLabel.alpha = 1.0
                  //  self.beatsPerMinuteLabel.text = String(heartRate)
                }, completion: { (true) in
                 //   self.beatsPerMinuteLabel.alpha = 0.0
                })
                
            } // END DispatchQueue.main.async...
            
        } // END if characteristic.uuid ==...
        
    } // END func peripheral(... didUpdateValueFor characteristic
    
    // MARK: - Utilities
    
    func getPSI(using pressureHEX: String ) -> Int {
        let pressure = Int(pressureHEX, radix: 32)
        return pressure!
    }

    func getKPA(using pressureHEX: String ) -> Int {
        let pressure = Int(pressureHEX, radix: 32)
        return pressure!
    }
    
    func getBar(using pressureHEX: String ) -> Int {
        let pressure = Int(pressureHEX, radix: 32)
        return pressure!
    }
    
    
    func readSensorLocation(using sensorLocationCharacteristic: CBCharacteristic) -> String {
        
        let sensorLocationValue = sensorLocationCharacteristic.value!
        // convert to an array of unsigned 8-bit integers
        let buffer = [UInt8](sensorLocationValue)
        var sensorLocation = ""
        
        // look at just 8 bits
        if buffer[0] == 1
        {
            sensorLocation = "Chest"
        }
        else if buffer[0] == 2
        {
            sensorLocation = "Wrist"
        }
        else
        {
            sensorLocation = "N/A"
        }
        
        return sensorLocation
        
    } // END func readSensorLocation
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
        case .connected:
            print("Peripheral state: connected")
        case .connecting:
            print("Peripheral state: connecting")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        }
        
    } // END func decodePeripheralState(peripheralState
    */
} // END class HeartRateMonitorViewController
