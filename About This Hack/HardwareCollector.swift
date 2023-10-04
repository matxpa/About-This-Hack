//
//  HardwareCollector.swift
//  HardwareCollector
//

import Foundation

let name = "\(HCStartupDisk.getStartupDisk())"

class HardwareCollector {
    static var macInfo: String = "Hackintosh Extreme Plus"
    static var SMBios: String = ""
    static var GPUstring: String = "Radeon Pro 560 4GB"
    static var DisplayString: String = "Generic LCD"
    static var SerialNumberString: String = "XXXXXXXXXXX"
    static var BootloaderString: String = ""
    static var BootloaderInfo: String = ""
    static var numberOfDisplays: Int = 1
    static var dataHasBeenSet: Bool = false
    static var displayRes: [String] = []
    static var displayNames: [String] = []
    static var storageType: Bool = false
    static var storageData: String = ""
    static var storagePercent: Double = 0.0
    static var devicelocation:String = ""
    static var deviceprotocol:String = ""
    
    static var qhasBuiltInDisplay: Bool = (macType == .LAPTOP)
    
    static var macType: macType = .LAPTOP
    
    static func getAllData() {
        if (dataHasBeenSet) {return}
        let queue = DispatchQueue(label: initGlobVar.dispatchQueue, attributes: .concurrent)
        
        queue.async {
            numberOfDisplays = getNumDisplays()
            print("Number of Displays: \(numberOfDisplays)")
            qhasBuiltInDisplay = hasBuiltInDisplay()
            print("Has built-in display: \(qhasBuiltInDisplay)")
            // getDisplayDiagonal() Having some issues, removing for now
        }
        
        queue.async {
            storageType = getStorageType()
            print("Storage Type: \(storageType)")
            storageData = getStorageData()[0]
            print("Storage Data: \(storageData)")
            storagePercent = Double(getStorageData()[1])!
            print("Storage Percent: \(storagePercent)")
        }
        
        // For some reason these don't work in groups, to be fixed
        displayRes = getDisplayRes()
        displayNames = getDisplayNames()
        
        dataHasBeenSet = true
    }
    
    static func getDisplayDiagonal() -> Float {
        return 13.3
    }
    
    static func getDisplayRes() -> [String] {
        let numDispl = getNumDisplays()
        if numDispl == 1 {
            return [run("grep -A1 \"_spdisplays_resolution\" " + initGlobVar.scrXmlFilePath + " | grep string | cut -c 15- | cut -f1 -d'<'")]
        }
        else if (numDispl > 1) {
            let tmp = run("grep \"Resolution\" " + initGlobVar.scrFilePath  + " | cut -c 23-")
            let tmpParts = tmp.components(separatedBy: "\n")
            return tmpParts
        }
        return []
    }
    
    static func getDisplayNames() -> [String] {
        let numDispl = getNumDisplays()
        // secondPart data extracted in all cases (numDispl =1, 2 or 3)
        let secondPart = run("grep \"        \" " + initGlobVar.scrFilePath + " | cut -c 9- | grep \"^[A-Za-z]\" | cut -f 1 -d ':'")
        
        if numDispl == 1 {
            if(qhasBuiltInDisplay) {
                return [run("echo $(grep \"Display Type\" " + initGlobVar.scrFilePath + " | cut -c 25-) $(grep -A2 \"</data>\" " + initGlobVar.scrXmlFilePath + " | awk -F'>|<' '/_name/{getline; print $3}') | tr -d '\n' ")]
            }
            else {
                return [secondPart]
            }
        }
        else if (numDispl == 2 || numDispl == 3) {
            print("2 or 3 displays found")
            let tmp = run("echo $(grep \"Display Type\" " + initGlobVar.scrFilePath + " | cut -c 25-)" + secondPart)
            let tmpParts = tmp.components(separatedBy: "\n")
            var toSend: [String] = []
            if(qhasBuiltInDisplay) {
                toSend.append(tmpParts[0])
                for i in 2...tmpParts.count-1 {
                    toSend.append(tmpParts[i])
                }
                return toSend
            }
            else {
                return [String](tmpParts.dropFirst())
            }
        }
        return []
    }
    
    static func getNumDisplays() -> Int {
        return Int(run("grep -c \"Resolution\" " + initGlobVar.scrFilePath + " | tr -d '\n'")) ?? 0x0
    }
    
    static func hasBuiltInDisplay() -> Bool {
        let tmp = run("grep \"Built-In\" " + initGlobVar.scrFilePath + " | tr -d '\n'")
        return !(tmp == "")
    }
    
    static func getStorageType() -> Bool {
        print("Startup Disk Name " + name)
        let storageType = run("grep \"Solid State:\" " + initGlobVar.bootvolnameFilePath)
        return storageType.contains("Yes")
        
    }
    
    static func getStorageData() -> [String] {
        deviceprotocol = run("grep \"Protocol:\" " + initGlobVar.bootvolnameFilePath + " | awk '{print $2}' | tr -d '\n'")
        devicelocation = run("grep \"Device Location:\" " + initGlobVar.bootvolnameFilePath + " | awk '{print $3}' | tr -d '\n'")
        let size = run("egrep \"[Container|Volume] Total Space:\" " + initGlobVar.bootvolnameFilePath + " | awk '{print $4,$5}'  | tr -d '\n'")
        let sizeTrimmed = run("echo \"\(size)\" | awk '{print $1}' | tr -d '\n'")
        let available = run("grep \"[Container|Volume] Free Space:\" " + initGlobVar.bootvolnameFilePath + " | awk '{print $4,$5}' | tr -d '\n'")
        let availableTrimmed = run("echo \"\(available)\" | awk '{print $1}' | tr -d '\n'")
        let percent = (Double(availableTrimmed)!) / Double(sizeTrimmed)!
        let percentfree = NSString(format: "%.2f",((Double(availableTrimmed)!) / Double(sizeTrimmed)! * 100))
        print("Size: \(sizeTrimmed)")
        print("Available: \(availableTrimmed)")
        print("%: \(percentfree)")
        return ["""
        \(name)
        (\(devicelocation) \(deviceprotocol))
        \(size) (\(available) available) (Free \(percentfree) %)
        """, String(1 - percent)]
    }
}
