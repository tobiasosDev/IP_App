//
//  bluetoothListController.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 06.08.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import CoreBluetooth
import UIKit
import Alamofire

class bluetoothListController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate
{
    
    
    //Variable declaration
    var centralManager: CBCentralManager?
    var dbServiceInstance = dbService()
    var peripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    var RSSIs: Array<NSNumber> = Array<NSNumber>()
    var nameDevice: String!
    var idDevice: String!
    var UUID: Foundation.UUID!
    let colorServiceInstance = colorService()
    var imagePicker: UIImagePickerController!
    let alertService: AlertService = AlertService()
    
    //Variable of outleted elements from Storyboard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanningCircle: UIActivityIndicatorView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        
        //make tableView background clear
        self.tableView.backgroundColor = UIColor.clear
        //set background with color gradient
        self.view.layer.insertSublayer(colorServiceInstance.backgroundGradientColor(self.view.bounds), at: 0)
        //set blur effect on statusbar
        self.view.addSubview(colorServiceInstance.getStandardStatusbarColorView())
    }
    
    //CoreBluetooth methods
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        //Check if bluetooth is on
        if (central.state == CBManagerState.poweredOn)
        {
            //Start scanning animation
            scanningCircle.startAnimating()
            //Start scanning of bluetooth devices
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        //If bluetooth is off
        else
        {
            //Create a alert Popup with information
            let alert = UIAlertController(title: "Bluetooth isn't on", message: "Please turn your Bluetooth on", preferredStyle: UIAlertControllerStyle.alert)
            //Add Action buttons to the Popup
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            //add alert Popup to the actual view
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //This method is called when a device was found
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        if(peripheral.name?.isEmpty == false){
            if(peripherals.contains(peripheral) == false){
        //Append the found device to the array
        peripherals.append(peripheral)
        //and his RSSI also
        RSSIs.append(RSSI)
        //Reload the Table Data
        tableView.reloadData()
            }
        }
    }
    
    //This function creates the List elements(cells)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Create a cell by identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! devicesToConnectCell
        //Get device by index of the Tableview element
        let peripheral = peripherals[(indexPath as NSIndexPath).row]
        //also the RSSI
        let rssi = RSSIs[(indexPath as NSIndexPath).row]
        //get the name of the device
        let name: String = peripheral.name!
        //outleted variables from devicesToConnectCell
        //set title
        cell.Title.text = "\(name)"
        //set RSSI
        cell.RSSILable.text = "\(rssi)db"
        //Return cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return peripherals.count
    }
    
    //This method has been called when the element was clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! devicesToConnectCell
        let name: String = cell.Title.text!
        
        peripherals.forEach { (CBPeripheralAk) in
            if(CBPeripheralAk.name == name){
                self.UUID = CBPeripheralAk.identifier
            }
        }
        nameDevice = name
        
        // 4. Present the alert.
        self.present(alertService.getTextFieldFuncAlert("Connect with IntelliPlug", alertMessage: "Enter the Pin from the \(name)", textFieldPlaceHolder: "ID", funct: self.addPlugChangeView), animated: true, completion: nil)
    }
    
    func addPlugChangeView(_textField: UITextField){
        print("Text field: \(String(describing: _textField.text))")
        self.idDevice = _textField.text
        _ = self.dbServiceInstance.insertPlug(self.nameDevice, UUID: self.UUID as NSUUID)
            .then{result in
                self.dbServiceInstance.getData()
            }.then{result -> Void in
                self.performSegue(withIdentifier: "activateDeviceSeque", sender: nil)
        }
    }
}
