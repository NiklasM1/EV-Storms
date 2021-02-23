//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
         newline
}

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {
	
//MARK: Variables
	var finished = true
	var alert = UIAlertController(title: "", message: "", preferredStyle: .alert)

//MARK: IBOutlets
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
	@IBOutlet weak var Demo_button: UIButton!

//MARK: IBFunctions
	@IBAction func info_button(_ sender: UIButton) {
		alerts(title: info_array[sender.tag][0], Text: info_array[sender.tag][1])
	}
	
	@IBAction func Demo(_ sender: Any) {
		if !serial.isReady {
			alerts(title: "Not connected", Text: "What am I supposed to send this to?")
		} else if !finished {
			alerts(title: "Not Finished", Text: "Please wait for the robot to finish before ordering more.")
		} else {
			var message:String = ""
			for x in output {
				message += String(x)
			}
			serial.sendMessageToDevice(message)
			print(message)
		}
	}
	
	@IBAction func Stepper(_ sender: UIStepper) {
		count = 0
		let current = gesamt
		let old_array = output[sender.tag]
		
		gesamt -= output[sender.tag]
		output[sender.tag] = Int(sender.value)
		gesamt += output[sender.tag]
		
		if current > 3 && gesamt > current || !finished {
			output[sender.tag] = old_array
			sender.value = Double(output[sender.tag])
			gesamt = current
		}
		
		gesamt_label.text = "\(gesamt)/4"
		
		if(gesamt>4 || gesamt < 1){
			gesamt_label.textColor = .red
			Demo_button.isEnabled = false
		} else {
			gesamt_label.textColor = .black
			Demo_button.isEnabled = true
		}
		
		switch sender.tag {
			case 0:
				out_label_0.text = Int(sender.value).description
			case 1:
				out_label_1.text = Int(sender.value).description
			case 2:
				out_label_2.text = Int(sender.value).description
			case 3:
				out_label_3.text = Int(sender.value).description
			default:
				print("")
		}
	}
	
	@IBOutlet weak var out_label_0: UILabel!
	@IBOutlet weak var out_label_1: UILabel!
	@IBOutlet weak var out_label_2: UILabel!
	@IBOutlet weak var out_label_3: UILabel!
	@IBOutlet weak var gesamt_label: UILabel!
	

//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			overrideUserInterfaceStyle = .light
		}
        
        serial = BluetoothSerial(delegate: self)
		
        reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            navItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }

	func alerts(title:String, Text:String){
		alert.dismiss(animated: true, completion: nil)
		alert = UIAlertController(title: title, message: Text, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
		present(alert, animated: true, completion: nil)
	}

//MARK: BluetoothSerialDelegate
    func serialDidReceiveString(_ message: String) {
		switch message {
			case "finished", "restart":
				reset()
				finished = true
				Demo_button.isEnabled = true
				alerts(title: "Finished", Text: "You may collect the medicin now.")
			case "start", "received":
				reset()
				finished = false
				Demo_button.isEnabled = false
			case "0","1","2","3","4":
				count = Int(message)!
				Image = UIImage(named: "Lego-\(count)")!
				Progress = Float(count)/Float(gesamt)
				if(count <= output[0]){label[0] = count}
				else if (count <= output[0]+output[1]) {label[1] = count - output[0]}
				else if (count <= output[0]+output[1]+output[2]) {label[2] = count - output[0] - output[1]}
				else if (count <= output[0]+output[1]+output[2]+output[3]) {label[3] = count - output[0] - output[1] - output[2]}
				if(count==gesamt){
					finished = true
					Demo_button.isEnabled = true
				}
			default:
				print("unknown message from arduino: \(message)")
		}
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
		reset()
		finished = true
		Demo_button.isEnabled = true
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
//MARK: IBActions
    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
			serial.sendMessageToDevice("88")
            serial.disconnect()
            reloadView()
        }
    }
}
