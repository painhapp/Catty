/**
 *  Copyright (C) 2010-2018 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import Foundation

class Header: NSObject {
    // meta infos
    var applicationBuildName: String? = ""
    var applicationBuildNumber: String? = ""
    var applicationName: String? = ""
    var applicationVersion: String? = ""
    var catrobatLanguageVersion: String? = ""
    var dateTimeUpload: Date?
    var programDescription: String? = ""
    var deviceName: String? = ""
    var mediaLicense: String? = ""
    var platform: String? = ""
    var platformVersion: String? = ""
    var programLicense: String? = ""
    var programName: String? = ""
    var remixOf: String? = ""
    var screenHeight: NSNumber?
    var screenWidth: NSNumber?
    var screenMode: String? = ""
    var url: String? = ""
    var userHandle: String? = ""
    var programScreenshotManuallyTaken: String? = ""
    var tags: String? = ""
    var isArduinoProject = false
    var landscapeMode = false
    // do not persist following properties
    var programID = ""
    
    func defaultHeader() -> Header {
        let header = Header()
        header.applicationBuildName = Util.appBuildName()!
        header.applicationBuildNumber = Util.appBuildVersion()!
        header.applicationName = Util.appName()!
        header.applicationVersion = Util.appVersion()!
        header.catrobatLanguageVersion = Util.catrobatLanguageVersion()!
        header.dateTimeUpload = nil
        header.programDescription = ""
        header.deviceName = Util.deviceName()!
        header.mediaLicense = Util.catrobatMediaLicense()!
        header.platform = Util.platformName()!
        header.platformVersion = Util.platformVersionWithoutPatch()!
        header.programLicense = Util.catrobatProgramLicense()!
        header.programName = ""
        header.remixOf = ""
        header.screenHeight = Util.screenHeight(true) as NSNumber
        header.screenWidth = Util.screenWidth(true) as NSNumber
        header.screenMode = kCatrobatHeaderScreenModeStretch
        header.url = ""
        header.userHandle = ""
        header.programScreenshotManuallyTaken = kCatrobatHeaderProgramScreenshotDefaultValue
        header.tags = ""
        header.programID = ""
        header.isArduinoProject = false
        header.landscapeMode = false
        return header
    }
    
    func updateRelevantHeaderInfosBeforeSerialization() {
        // needed to update headers in catrobat programs that have not been
        // created on this device (e.g. downloaded programs...)
        applicationBuildName = Util.appBuildName()!
        applicationBuildNumber = Util.appBuildVersion()!
        applicationName = Util.appName()!
        applicationVersion = Util.appVersion()!
        applicationVersion = Util.appVersion()!
        deviceName = Util.deviceName() ?? ""
        mediaLicense = Util.catrobatMediaLicense()! // always use most recent license!
        platform = Util.platformName()!
        platformVersion = Util.platformVersionWithoutPatch()!
        programLicense = Util.catrobatProgramLicense()! // always use most recent license!
        
        // now, this becomes a remixed version
        // ... but URL must be valid ...
        if !url!.isEmpty && (url!.hasPrefix("http://") || url!.hasPrefix("https://")) {
            remixOf = url
        }
        
        // invalidate all web fields (current user now becomes the creator of this remix!)
        tags = ""
        userHandle = ""
    }
    
    func isEqual(to header: Header?) -> Bool {
        if !(applicationName == header?.applicationName) {
            return false
        }
        if !(programDescription == header?.programDescription) {
            return false
        }
        if !(mediaLicense == header?.mediaLicense) {
            return false
        }
        if !(programLicense == header?.programLicense) {
            return false
        }
        if !(programName == header?.programName) {
            return false
        }
        if !(screenHeight == header?.screenHeight) {
            return false
        }
        if !(screenWidth == header?.screenWidth) {
            return false
        }
        if !(screenMode == header?.screenMode) {
            return false
        }
        if !(url == header?.url) {
            return false
        }
        if landscapeMode != header?.landscapeMode {
            return false
        }
        return true
    }
}
