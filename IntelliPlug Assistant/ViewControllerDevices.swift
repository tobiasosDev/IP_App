//
//  ViewControllerDevices.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 07.08.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import CoreBluetooth

class ViewControllerDevices: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, UIViewControllerPreviewingDelegate, CBPeripheralDelegate {
    
    //Varibale declaration
    var deviceActive: Device!
    var deviceList: Results<Device> = {
        // Do any additional setup after loading the view, typically from a nib.
        //Instance realm
        let realm = try! Realm()
        return realm.objects(Device.self)
    }()
    var dbNotificationToken: NotificationToken?
    var deviceUUIDs: Array<UUID> = Array<UUID>()
    let colorServiceInstance = colorService()
    var centralManager: CBCentralManager?
    var connectedDevice: CBPeripheral?

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingDataIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingDataIndicator.hidesWhenStopped = true;
        
        //start animating
        loadingDataIndicator.startAnimating()
        
        dbNotificationToken = deviceList.addNotificationBlock {[weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            
            switch changes {
            case .initial:
                tableView.reloadData()
                self?.deviceUUIDs.removeAll()
                // Query Realm
                self?.deviceList.forEach { (device) in
                    //add elements from DB to Arrays
                    self?.deviceUUIDs.append(NSUUID(uuidString: device.adress)! as UUID)
                }
                break
            case .update( _, let deletions, let insertions, let modifications):
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                           with: .automatic)
                self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0)},
                                           with: .automatic)
                self?.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
                                           with: .automatic)
                self?.tableView.endUpdates()
                
                self?.deviceUUIDs.removeAll()
                // Query Realm
                self?.deviceList.forEach { (device) in
                    //add elements from DB to Arrays
                    self?.deviceUUIDs.append(NSUUID(uuidBytes: device.adress) as UUID)
                }
                
                break
            case .error(let error):
                print(error)
                break
            }
        }
        

        //Delegate CoreBluetooth
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        
        //Some Visuall Tweaks
        self.tableView.backgroundColor = UIColor.clear
        self.view.layer.insertSublayer(colorServiceInstance.backgroundGradientColor(self.view.bounds), at: 0)
        self.view.addSubview(colorServiceInstance.getStandardStatusbarColorView())
        
        //stop spin animation
        self.loadingDataIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Table methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return deviceList.count
        
    }
    
    //This function creates the List elements(cells)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! deviceCell
        
        //Read device by index
        deviceActive = deviceList[(indexPath as NSIndexPath).row]
        
        //Print Device to check
        print("Device: \(deviceActive.name)")
        
        //Set text of the cell
        cell.plugName.text = deviceActive.name
        
        //Set picture
        cell.devicePicture.image = UIImage(named: "sample1")
        
        //Set Connected devices
        cell.connectedDevices.text = "\(3) Geräte aktiv"
                
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Read device by index of the table element
        deviceActive = deviceList[(indexPath as NSIndexPath).row]
        
        //Change View
        self.performSegue(withIdentifier: "detailDeviceViewSeque", sender: nil)
    }
    
    //Prepare View change
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        //Check with change would did
        if (segue.identifier == "detailDeviceViewSeque") {
            //read View by segue
            let detailVC = segue.destination as! deviceDetailView;
            //set variable to store
            let realm = try! Realm()
            detailVC.deviceActive = realm.objects(Device.self).filter("dbID == '\(self.deviceActive.dbID)'")
        }
    }
    
    //Edit Actions for the table elements(cell's)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Get dbService instance
        let dbServiceInstance = dbService()
        //create slide Button Delete
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //here comes the code which would executed by click
            //Read device by index of the table element
            let myDevice = self.deviceList[(indexPath as NSIndexPath).row]
            //Delete device with dbService
            _ = dbServiceInstance.deletePlugByName(myDevice.dbID).then{result -> Void in
            //Also delete Device in local DB
            let realm = try! Realm()
            try! realm.write {
                realm.delete(myDevice)
            }
            }
        }
        //Set the background color of the button
        delete.backgroundColor = UIColor.red
        //Return the created button
        return [delete]
    }
    
    //CoreBluetooth methods
    @objc func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        //Check Prints
        print("-----------------Test--------------------")
        //Check if bluetooth is on
        if (central.state == CBManagerState.poweredOn)
        {
            //Check Prints
            print("-----------------Service Running--------------------")
            //Start scanning if bluetooth is on
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else
        {
            
        }
    }
    
    //This method is called when a device was found
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        //Check Prints
        //print("-----------------Found Device--------------------")
        //Check if a know device is in area
        if(deviceUUIDs.contains(peripheral.identifier)){
            //Connect with the device
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    //This method is called when you are connected to the device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //Check Prints
        print("-----------------Connected--------------------")
        self.connectedDevice = peripheral
        self.connectedDevice?.delegate = self
        let string = "test"
        let write: CBCharacteristicWriteType = CBCharacteristicWriteType.withResponse
        var txCharacteristic:CBCharacteristic?
        for service in (self.connectedDevice?.services!)! {
            txCharacteristic = service.characteristics?[0]
        }
        let data = NSData(bytes: string, length: string.utf16.count)
        self.connectedDevice?.writeValue(data as Data, for: txCharacteristic!, type: write)

    }
    
    
    //3D Touch Peek Preview Codes
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let indexPath: IndexPath = tableView.indexPathForRow(at: location)!
        
        guard let detailViewController =
            storyboard?.instantiateViewController(
                withIdentifier: "detailDeviceView") as?
            deviceDetailView else { return nil }
        
        let realm = try! Realm()
        detailViewController.deviceActive = realm.objects(Device.self).filter("dbID == '\(deviceList[indexPath.row].dbID)'")
        detailViewController.viewControllerDevices = self
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: 600)
        
        
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        
        
        return detailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }
    
    //Check if 3D touch is available
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        switch traitCollection.forceTouchCapability {
        case .available:
            registerForPreviewing(with: self, sourceView: tableView)
        case .unavailable:
            print("3D Touch Not Available")
        case .unknown:
            print("Unknown")
        }
    }

}
