//
//  deviceDetailView.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 07.08.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import UIKit
import RealmSwift
//Not available at the moment
//import Charts

class deviceDetailView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Varibale
    var deviceActive: Results<Device>!
    var dbNotificationToken: NotificationToken?
    let plugs = ["Plug1", "Plug2", "Plug3"]
    let colorServiceInstance: colorService = colorService()
    let dbServiceInstance: dbService = dbService()
    let alertService: AlertService = AlertService()
    var viewControllerDevices: ViewControllerDevices!
    
    //LinkedViewObjects
    @IBOutlet weak var plugList: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    //TestVariable
    let months = ["Jan" , "Feb", "Mar", "Apr", "May", "June", "July", "August", "Sept", "Oct", "Nov", "Dec"]
    let dollars1 = [1453.0,2352,5431,1442,5451,6486,1173,5678,9234,1345,9411,2212]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.plugList.backgroundColor = UIColor.clear
        //        self.testChart.backgroundColor = UIColor.clearColor()
        self.view.layer.insertSublayer(colorServiceInstance.backgroundGradientColor(self.view.bounds), at: 0)
        self.view.addSubview(colorServiceInstance.getStandardStatusbarColorView())
        
        
        dbNotificationToken = deviceActive.addNotificationBlock {[weak self] (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                self?.navigationBarItem.title! = (self?.deviceActive.first?.name)!
                break
            case .update( _, let deletions, _, _):
                if(deletions.count == 0){
                    self?.navigationBarItem.title! = (self?.deviceActive.first?.name)!
                }
                break
            case .error(let error):
                print(error)
                break
            }
        }
        
        //
        //
        //
        //
        //
        //        //ChartTest
        //        self.testChart.delegate = self
        //        // 2
        //        self.testChart.descriptionText = ""
        //        // 3
        //        self.testChart.descriptionTextColor = UIColor.whiteColor()
        //        self.testChart.gridBackgroundColor = UIColor.darkGrayColor()
        //        // 4
        //        self.testChart.noDataText = "No data provided"
        //        // 5
        //        setChartData(months)
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteThisPlug() {
        //Delete device with dbService
        _ = dbServiceInstance.deletePlugByName((deviceActive.first?.dbID)!).then{result -> Void in
            //Also delete Device in local DB
            let realm = try! Realm()
            try! realm.write {
                realm.delete(self.deviceActive)
            }
        }
        self.performSegue(withIdentifier: "plugIsDeleted", sender: nil)
    }
    
    func renameThisPlug(textField: UITextField){
        _ = dbServiceInstance.updatePlug(dbId: (self.deviceActive.first?.dbID)!, updateEnum: "name", updateValue: textField.text!)
        print(deviceActive)
    }
    
    func tableView(_ plugList: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.plugs.count
        
    }
    
    
    func tableView(_ plugList: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = plugList.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        // Configure the cell...
        
        cell.textLabel?.text = self.plugs[(indexPath as NSIndexPath).row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let turnOff = UITableViewRowAction(style: .normal, title: "Turn off") { action, index in
        }
        turnOff.backgroundColor = UIColor.red
        
        let turnOn = UITableViewRowAction(style: .normal, title: "Turn on") { action, index in
        }
        turnOn.backgroundColor = UIColor.green
        
        return [turnOn, turnOff]
    }
    
    //    func setChartData(_ months : [String]) {
    //        // 1 - creating an array of data entries
    //        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
    //        for i in 0 ..< months.count {
    //            yVals1.append(ChartDataEntry(value: dollars1[i], xIndex: i))
    //        }
    //
    //        // 2 - create a data set with our array
    //        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: "")
    //        set1.axisDependency = .Left // Line will correlate with left axis values
    //        set1.setColor(UIColor.redColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
    //        set1.setCircleColor(UIColor.redColor()) // our circle will be dark red
    //        set1.lineWidth = 2.0
    //        set1.circleRadius = 6.0 // the radius of the node circle
    //        set1.fillAlpha = 65 / 255.0
    //        set1.fillColor = UIColor.redColor()
    //        set1.highlightColor = UIColor.blackColor()
    //        set1.drawCircleHoleEnabled = true
    //
    //        //3 - create an array to store our LineChartDataSets
    //        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
    //        dataSets.append(set1)
    //
    //        //4 - pass our months in for our x-axis label value along with our dataSets
    //        let data: LineChartData = LineChartData(xVals: months, dataSets: dataSets)
    //        data.setDrawValues(false)
    //        testChart.setScaleEnabled(false)
    //        testChart.legend.enabled = false
    //
    //        //5 - finally set our data
    //        self.testChart.data = data
    //    }
    
    @IBAction func editPlug(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action) -> Void in
            self.present(self.alertService.getTextFieldFuncAlert("Rename IntelliPlug", alertMessage: "Enter a new Name for \((self.deviceActive.first?.name)!)", textFieldPlaceHolder: "\((self.deviceActive.first?.name)!)", funct: self.renameThisPlug), animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //3D Touch actions
    override var previewActionItems: [UIPreviewActionItem] {
        let turnOnAction = UIPreviewAction(title: "Turn On",
                                           style: .default,
                                           handler: { previewAction, viewController in
                                            print("Turned on")
        })
        
        let renameAction = UIPreviewAction(title: "Rename",
                                           style: .default,
                                           handler: { previewAction, viewController in
                                            
                                            
                                            self.viewControllerDevices.present(self.alertService.getTextFieldFuncAlert("Rename IntelliPlug", alertMessage: "Enter a new Name for \((self.deviceActive.first?.name)!)", textFieldPlaceHolder: "\((self.deviceActive.first?.name)!)", funct: self.renameThisPlug), animated: true, completion: nil)
        })
        
        
        let deleteAction = UIPreviewAction(title: "Delete",
                                           style: .destructive,
                                           handler: { previewAction, viewController in
                                            print("Plug Deleted")
                                            //Todo delete Plug
                                            (viewController as! deviceDetailView).deleteThisPlug()
        })
        
        let deviceAction1 = UIPreviewAction(title: self.plugs[0],
                                            style: .default,
                                            handler: { previewAction, viewController in
                                                print(self.plugs[0])
        })
        
        let deviceAction2 = UIPreviewAction(title: self.plugs[1],
                                            style: .default,
                                            handler: { previewAction, viewController in
                                                print(self.plugs[1])
        })
        
        let deviceAction3 = UIPreviewAction(title: self.plugs[2],
                                            style: .default,
                                            handler: { previewAction, viewController in
                                                print(self.plugs[2])
        })
        
        let groupActions = UIPreviewActionGroup(title: "Devices",
                                                style: .default,
                                                actions: [deviceAction1, deviceAction2, deviceAction3])
        
        return [turnOnAction, renameAction, deleteAction, groupActions]
    }
    
}
