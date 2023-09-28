//
//  ViewControllerDisplays.swift
//  ViewControllerDisplays
//
//

import Foundation
import Cocoa

class ViewControllerStorage: NSViewController {

    @IBOutlet weak var startupDiskImage: NSImageView!
    @IBOutlet weak var storageValue: NSTextField!


    @IBOutlet weak var storageAmount: NSLevelIndicatorCell!
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override var representedObject: Any? {
        didSet {
        }
    }

    override func viewDidAppear() {
        self.view.window?.styleMask.remove(NSWindow.StyleMask.resizable)
        start()
        setToolTips()
    }

    func start() {
        print("Initializing Storage View...")
        
        if (!HardwareCollector.dataHasBeenSet) {HardwareCollector.getAllData()}

        // Image
        startupDiskImage.image = NSImage(named: "HDD")              // Default Value
        let imageShortName = (HCVersion.OSname + " " + HardwareCollector.devicelocation)
        switch HardwareCollector.getStorageType() {
            case true: startupDiskImage.image = NSImage(named: imageShortName + " SSD")
            case false:startupDiskImage.image = NSImage(named: imageShortName + " HDD")
        }

        // Text
        storageValue.stringValue = HardwareCollector.storageData
        storageAmount.doubleValue = HardwareCollector.storagePercent*1000000
    }
    
    func setToolTips(){
        startupDiskImage.toolTip = startupDiskImagetoolTip
        storageValue.toolTip     = storageValuetoolTip
    }
}
