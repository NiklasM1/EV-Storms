//
//  PreferencesTableViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit

final class PreferencesTableViewController: UITableViewController {
    
//MARK: Variables
    
    var selectedMessageOption: MessageOption!
    var selectedReceivedMessageOption: ReceivedMessageOption!

	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var progess: UIProgressView!
	@IBOutlet weak var label_0: UILabel!
	@IBOutlet weak var label_1: UILabel!
	@IBOutlet weak var label_2: UILabel!
	@IBOutlet weak var label_3: UILabel!
	
	var timer = Timer()
	
//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			// Always adopt a light interface style.
			overrideUserInterfaceStyle = .light
		}
		
		self.update()
        
        // get current prefs
        selectedMessageOption = MessageOption(rawValue: UserDefaults.standard.integer(forKey: MessageOptionKey))
        selectedReceivedMessageOption = ReceivedMessageOption(rawValue: UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey))
		scheduledTimerWithTimeInterval()
    }
	
	func scheduledTimerWithTimeInterval(){
		// Scheduling timer to Call the function "update" with the interval of 1 seconds
		timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
			self.update()
		}
	}
	
	func update(){
		self.image.image = Image
		self.progess.progress = Progress
		self.label_0.text = "\(label[0])/\(output[0])"
		self.label_1.text = "\(label[1])/\(output[1])"
		self.label_2.text = "\(label[2])/\(output[2])"
		self.label_3.text = "\(label[3])/\(output[3])"
	}

    
//MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        // is it for the selectedMessageOption or for the selectedReceivedMessageOption? (section 0 or 1 resp.)
        if (indexPath as NSIndexPath).section == 0 {
            
            // first clear the old checkmark
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.accessoryType = .none
            tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.accessoryType = .none
            tableView.cellForRow(at: IndexPath(row: 2, section: 0))?.accessoryType = .none
            tableView.cellForRow(at: IndexPath(row: 3, section: 0))?.accessoryType = .none
            
            // get the newly selected option
            let selectedCell = (indexPath as NSIndexPath).row
            selectedMessageOption = MessageOption(rawValue: selectedCell)

            // set new checkmark
            tableView.cellForRow(at: IndexPath(row: selectedCell, section: 0))?.accessoryType = UITableViewCell.AccessoryType.checkmark
            
            // and finally .. save it
            UserDefaults.standard.set(selectedCell, forKey: MessageOptionKey)
            
        } else if (indexPath as NSIndexPath).section == 1 {
            
            // first, clear the old checkmark
            tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.accessoryType = .none
            tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.accessoryType = .none
            
            // get the newly selected option
            let selectedCell = (indexPath as NSIndexPath).row
            selectedReceivedMessageOption = ReceivedMessageOption(rawValue: selectedCell)

            // set new checkmark
            tableView.cellForRow(at: IndexPath(row: selectedCell, section: 1))?.accessoryType = UITableViewCell.AccessoryType.checkmark
            
            // save it
            UserDefaults.standard.set(selectedCell, forKey: ReceivedMessageOptionKey)

        }
        
        // deselect row
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    
//MARK: IBActions
    @IBAction func done(_ sender: AnyObject) {
        // dismissssssss
        dismiss(animated: true, completion: nil)
    }
}

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white { didSet { setNeedsDisplay() } }
    @IBInspectable var bottomColor: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
