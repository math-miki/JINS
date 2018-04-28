//
//  ViewController.swift
//  JINS
//
//  Created by 八木康輔 on 2018/04/25.
//  Copyright © 2018年 patchgi. All rights reserved.
//

import UIKit
import Foundation
import Darwin
import SocketIO

class ViewController: UIViewController, MEMELibDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var accZ: UILabel!
    
    @IBOutlet weak var yaw: UILabel!
    @IBOutlet weak var roll: UILabel!
    @IBOutlet weak var pitch: UILabel!
    
    @IBOutlet weak var eyeMoveUp: UILabel!
    @IBOutlet weak var eyeMoveDown: UILabel!
    @IBOutlet weak var eyeMoveLeft: UILabel!
    @IBOutlet weak var eyeMoveRight: UILabel!
    
    @IBOutlet weak var blinkStrength: UILabel!
    @IBOutlet weak var blinkSpeed: UILabel!
    
    @IBOutlet weak var isWalking: UILabel!
    
    @IBOutlet weak var powerLeft: UILabel!
    
    @IBOutlet weak var url_field: UITextField!
    @IBOutlet weak var submit: UIButton!
    var manager:SocketManager!
    var socket:SocketIOClient!
    var url =  "http://192.168.100.84:8888"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        url_field.placeholder = "URLを入力"
        url_field.clearButtonMode = .always
        url_field.returnKeyType = .done
        manager = SocketManager(socketURL: URL(string: url)!, config: [.log(true), .compress])
        socket = manager.defaultSocket
        MEMELib.sharedInstance().delegate = self
       
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    func memeAppAuthorized(_ status: MEMEStatus) {
        MEMELib.sharedInstance().startScanningPeripherals()
        self.checkMEMEStatus(status)
    }
    
    func memePeripheralFound(_ peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        MEMELib.sharedInstance().connect(peripheral)
    }
    
    func memePeripheralConnected(_ peripheral: CBPeripheral!) {
        let status = MEMELib.sharedInstance().startDataReport()
        print(status)
    }

    @IBAction func submit(_ sender: Any) {
        url = url_field.text!
        manager = SocketManager(socketURL: URL(string: url)!, config: [.log(true), .compress])
        socket = manager.defaultSocket
        url_field.endEditing(true)
    }
    
    func memeRealTimeModeDataReceived(_ data: MEMERealTimeData!) {
        
        let row_sensor_data = data.description.components(separatedBy: "{")[1].components(separatedBy: "}")[0].components(separatedBy: ";").map{$0.replacingOccurrences(of:" ", with:"")}
        var sensor_data = Dictionary<String, String>()
        for _datam in row_sensor_data{
            let datam = _datam.components(separatedBy: "=")
            if (datam.count > 1){
                let k = datam[0]
                let v = (datam[1])
                sensor_data[k] = v
            }
        }
        socket.emit("data", sensor_data)
        socket.connect()
        accX.text = "accX: " + sensor_data["accX"]!
        accY.text = "accY: " + sensor_data["accY"]!
        accZ.text = "accZ: " + sensor_data["accZ"]!
        
        yaw.text = "yaw: " + sensor_data["yaw"]!
        roll.text = "roll: " + sensor_data["roll"]!
        pitch.text = "pitch: " + sensor_data["pitch"]!
        
        eyeMoveUp.text = "eyeMoveUp: " + sensor_data["eyeMoveUp"]!
        eyeMoveDown.text = "eyeMoveDown: " + sensor_data["eyeMoveDown"]!
        eyeMoveLeft.text = "eyeMoveLeft: " + sensor_data["eyeMoveLeft"]!
        eyeMoveRight.text = "eyeMoveRight: " + sensor_data["eyeMoveRight"]!
        
        blinkStrength.text = "blinkStrength: " + sensor_data["blinkStrength"]!
        blinkSpeed.text = "blinkSpeed: " + sensor_data["blinkSpeed"]!
        
        isWalking.text = "isWalking: " + sensor_data["isWalking"]!
        
        powerLeft.text = "powerLeft: " + sensor_data["powerLeft"]!
        
        
    }
    func checkMEMEStatus(_ status:MEMEStatus) {
        
        if status == MEME_ERROR_APP_AUTH {
            let alertController = UIAlertController(title: "App Auth Failed", message: "Invalid Application ID or Client Secret ", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler:nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        } else if status == MEME_ERROR_SDK_AUTH{
            let alertController = UIAlertController(title: "SDK Auth Failed", message: "Invalid SDK. Please update to the latest SDK.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler:nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        } else if status == MEME_CMD_INVALID {
            let alertController = UIAlertController(title: "SDK Error", message: "Invalid Command", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler:nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        } else if status == MEME_ERROR_BL_OFF {
            let alertController = UIAlertController(title: "Error", message: "Bluetooth is off.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler:nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        } else if status == MEME_OK {
            print("Status: MEME_OK")
        }
    }
}

