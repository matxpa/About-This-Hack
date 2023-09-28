import Foundation

class HCSerialNumber {
    
    static func getSerialNumber() -> String {
        return run("awk '/Serial/ {print $4}' " + initGlobVar.hwFilePath)
    }
    
    static func getHardWareInfo() -> String {
        return run("cat " + initGlobVar.hwFilePath + " | egrep \"[System Firmware |OS Loader |SMC ]Version|Apple ROM Info:|Board-ID :|Hardware UUID:|Provisioning UDID:\" | sed -e 's/^ *//g' -e 's/^/      /g'")

// Uncredible the code below returns nothing, the same code above with a "cat file" before "egrep" returns the expected informations
//        return run("egrep \"System Firmware |OS Loader |SMC ]Version|Apple ROM Info:|Board-ID :|Hardware UUID:|Provisioning UDID:\" " + initGlobVar.hwFilePath + " | sed -e 's?^ *??00g' -e 's?^?      ?g'")
    }
}
