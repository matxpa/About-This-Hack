class HCRAM {
    
    static func getRam() -> String {
        let memInfo = run("echo \"$(($(sysctl -n hw.memsize) / 1073741824))\" | tr -d '\n'")
        let ramType = run("grep 'Type' " + initGlobVar.sysmemFilePath + " | awk '{print $2}' | sed -n '1p'")
        let ramSpeed = run("grep 'Speed' " + initGlobVar.sysmemFilePath + " | grep 'MHz' | awk '{print $2\" \"$3}' | sed -n '1p'").trimmingCharacters(in: .whitespacesAndNewlines)

        var result = "\(memInfo) GB"
        if ramType.contains("D") { result += " \(ramType)" }
        if !ramSpeed.isEmpty { result += " \(ramSpeed)" }
        return result
    }
    
    static func getMemDesc() -> String {
        return run("echo \"$(egrep \"ECC:|BANK |Size:|Type:|Speed:|Manufacturer:|Part Number:\" " + initGlobVar.sysmemFilePath + ")\"")
    }

    // Another Data display way
    static func getMemDescArray() -> String {
        var memInfoFormatted = ""
        let memoryDataTmp = run("echo $(egrep \"BANK |Size:|Type:|Speed:|Manufacturer:|Part Number:\" " + initGlobVar.sysmemFilePath + " | sed -e 's/$/ /g' -e 's/^. *//g' -e 's/:/: /g' -e 's/:  /: /g' | tr -d '\n' | sed 's/BANK /\\nBANK /g' )")
        let memoryDataArray = memoryDataTmp.components(separatedBy: "BANK ").filter({ $0 != ""})
        for index in 0..<memoryDataArray.count {
            memInfoFormatted += ("BANK " + "\(memoryDataArray[index])" + run("echo \"\n\""))
        }
        return "\(memInfoFormatted)"
    }
}
