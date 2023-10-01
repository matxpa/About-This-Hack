import Foundation
import AppKit
import Zip

class UpdateController {
    static func checkForUpdates() -> Bool {
        print("Checking for updates...")
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        _ = run("curl -o" + " " + initGlobVar.athtargetversionfile + " " + initGlobVar.athsourceversionfile)
        let latestVersion = run("tr -d '[:space:]' < " + initGlobVar.athtargetversionfile)
        if appVersion < latestVersion {
            print("Newer version (" + latestVersion + ") available")
            let prompt = alert(message: "Update found!", text: "The latest version is " + latestVersion + ". You are currently running " + appVersion + ".")
            print("Done")
            return prompt
        }
        return false
    }
    
    static func alert(message: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = text
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Update")
        alert.addButton(withTitle: "Skip")
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    static func updateATH() {
        print("Starting Update...")
        print("Starting Download...")
        notify(title: "Starting Download", informativeText: "This may take awhile...")
        _ = run("curl -L " + initGlobVar.lastAthreleaseURL + run("tr -d '[:space:]' <  " + initGlobVar.athtargetversionfile) +  initGlobVar.newAthziprelease + " -o " + initGlobVar.newAthreleasezip)
        print("Killing Old App...")
        notify(title: "Replacing Apps", informativeText: "Deleting the old version and replacing it with the new version")
        // Thanks for the code, Ben216k
        let rm = run("rm -rf \"" + initGlobVar.thisAppliLocation + "\"")
        if rm.contains("No") {
            notify(title: "Failed to delete the old copy of About This Hack.app", informativeText: "Please make sure it is in the Applications folder!!!")
            return
        }
        _ = run("[[ ! -d \"" + initGlobVar.thisAppliLocation + "\" ]]")
        print("Unzipping Archive...")
        notify(title: "Unzipping Archive", informativeText: "")
        do {
            _ = try Zip.unzipFile(URL(string: " " + initGlobVar.newAthreleasezip)!, destination: URL(string: " " + initGlobVar.athDirectory)!, overwrite: true, password: "")
        } catch {
            print(error)
        }
        
         print("Copying New Version...")
        notify(title: "Copying New Version", informativeText: "Almost there!")
        _ = run("cp -rf " + initGlobVar.athDirectory + "\"" + initGlobVar.thisAppliname + "\" " + initGlobVar.allAppliLocation)

        notify(title: "Update Complete!", informativeText: "Launching New Version...")
        _ = run("open " + initGlobVar.allAppliLocation + "\"" + initGlobVar.thisAppliname + "\"")
        exit(0)    }
    
    static func notify(title: String, informativeText: String) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = informativeText
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}
