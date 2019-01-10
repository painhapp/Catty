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

class Program: NSObject {
    var header: Header!
    
    private var _objectList: [SpriteObject] = []
    var objectList: [SpriteObject] {
        get {
            #if false
            if !_objectList {
                if let anArray = [AnyHashable]() as? [SpriteObject] {
                    _objectList = anArray
                }
            }
            #endif
            return _objectList
        }
        set(objectList) {
            for object: Any? in objectList ?? [] {
                if (object is SpriteObject) {
                    (object as? SpriteObject)?.program = self
                }
            }
            _objectList = objectList
        }
    }
    
    private var _variables: VariablesContainer?
    var variables: VariablesContainer {
        // lazy instantiation
        if _variables == nil {
            _variables = VariablesContainer()
        }
        return _variables
    }
    var requiresBluetooth = false
    
    func numberOfTotalObjects() -> Int {
        return objectList.count
    }
    
    func numberOfBackgroundObjects() -> Int {
        let numberOfTotalObjects: Int = self.numberOfTotalObjects()
        if numberOfTotalObjects < kBackgroundObjects {
            return numberOfTotalObjects
        }
        return Int(kBackgroundObjects)
    }
    
    func numberOfNormalObjects() -> Int {
        let numberOfTotalObjects: Int = self.numberOfTotalObjects()
        if numberOfTotalObjects > kBackgroundObjects {
            return numberOfTotalObjects - Int(kBackgroundObjects)
        }
        return 0
    }
    
    func addObject(withName objectName: String?) -> SpriteObject? {
        let object = SpriteObject()
        //object.originalSize;
        object.spriteNode?.currentLook = nil
        
        object.name = Util.uniqueName(objectName, existingNames: allObjectNames())!
        object.program = self
        objectList.append(object)
        saveToDisk(withNotification: true)
        return object
    }
    
    func removeObjects(_ objects: [Any]) {
        for object: Any in objects {
            if (object is SpriteObject) {
                remove(object as? SpriteObject)
            }
        }
        saveToDisk(withNotification: true)
    }
    
    func remove(_ object: SpriteObject?) {
        removeObject(fromList: object)
        saveToDisk(withNotification: true)
    }
    
    func removeObject(fromList object: SpriteObject?) {
        // do not use NSArray's removeObject here
        // => if isEqual is overriden this would lead to wrong results
        var index: Int = 0
        for currentObject: SpriteObject in objectList {
            if currentObject == object {
                currentObject.removeSounds(currentObject.soundList, andSaveToDisk: false)
                currentObject.removeLooks(currentObject.lookList, andSaveToDisk: false)
                currentObject.program?.variables.removeObjectVariables(for: currentObject)
                currentObject.program?.variables.removeObjectLists(for: currentObject)
                currentObject.program = nil
                objectList.remove(at: index)
                break
            }
            index += 1
        }
    }
    
    func projectPath() -> String? {
        return Program.projectPathForProgram(withName: Util.replaceBlockedCharacters(for: header.programName), programID: header.programID)
    }
    
    func removeFromDisk() {
        Program.removeProgramFromDisk(withProgramName: Util.enableBlockedCharacters(for: header.programName), programID: header.programID)
    }
    
    @objc func removeReferences() {
        objectList.makeObjectsPerform(#selector(Program.removeReferences))
    }
    
    func saveToDisk(withNotification notify: Bool) {
        let fileManager = CBFileManager.shared()
        let saveToDiskQ = DispatchQueue(label: "save to disk")
        saveToDiskQ.async(execute: {
            // show saved view bezel
            if notify {
                DispatchQueue.main.sync(execute: {
                    let notificationCenter = NotificationCenter.default
                    notificationCenter.post(name: NSNotification.Name(rawValue: kHideLoadingViewNotification), object: self)
                    notificationCenter.post(name: NSNotification.Name(rawValue: kShowSavedViewNotification), object: self)
                })
            }
            // TODO: find correct serializer class dynamically
            let xmlPath = "\(self.projectPath() ?? "")\(kProgramCodeFileName)"
            let serializer = CBXMLSerializer(path: xmlPath, fileManager: fileManager) as? CBSerializerProtocol
            serializer?.serializeProgram(self)
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHideLoadingViewNotification), object: self)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReadyToUpload), object: self)
            })
        })
    }
    
    func isLastUsedProgram() -> Bool {
        return Program.isLastUsedProgram(header.programName, programID: header.programID)
    }
    
    func setAsLastUsedProgram() {
        Program.setLastUsed(self)
    }
    
    func translateDefaultProgram() {
        var index: Int = 0
        for spriteObject: SpriteObject in objectList {
            if index == kBackgroundObjectIndex {
                spriteObject.name = kLocalizedBackground
            } else {
                var spriteObjectName = spriteObject.name
                if let subRange = Range<String.Index>(NSRange(location: 0, length: spriteObjectName.count), in: spriteObjectName) { spriteObjectName = spriteObjectName.replacingOccurrences(of: kDefaultProgramBundleOtherObjectsNamePrefix, with: kLocalizedMole, options: .caseInsensitive, range: subRange) }
                spriteObject.name = spriteObjectName
            }
            index += 1
        }
        rename(toProgramName: kLocalizedMyFirstProgram) // saves to disk!
    }
    
    func rename(toProgramName programName: String?) {
        if (header.programName == programName) {
            return
        }
        let isLastProgram: Bool = isLastUsedProgram()
        let oldPath = projectPath()
        header.programName = Util.uniqueName(programName, existingNames: allProgramNames())!
        let newPath = projectPath()
        CBFileManager.shared().moveExistingDirectory(atPath: oldPath, toPath: newPath)
        if isLastProgram {
            Util.setLastProgramWithName(header.programName, programID: header.programID)
        }
        saveToDisk(withNotification: true)
    }
    
    func renameObject(_ object: SpriteObject?, toName newObjectName: String?) {
        if !hasObject(object) || (object?.name == newObjectName) {
            return
        }
        object?.name = Util.uniqueName(newObjectName, existingNames: allObjectNames())!
        saveToDisk(withNotification: true)
    }
    
    func updateDescription(withText descriptionText: String?) {
        header.programDescription = descriptionText ?? ""
        saveToDisk(withNotification: true)
    }
    
    func allObjectNames() -> [Any]? {
        var objectNames = [AnyHashable](repeating: 0, count: objectList.count)
        for spriteObject: Any in objectList {
            if (spriteObject is SpriteObject) {
                objectNames.append((spriteObject as? SpriteObject)?.name ?? "")
            }
        }
        return objectNames
    }
    
    func hasObject(_ object: SpriteObject?) -> Bool {
        if let anObject = object {
            return objectList.contains(anObject)
        }
        return false
    }
    
    func copy(_ sourceObject: SpriteObject?, withNameForCopiedObject nameOfCopiedObject: String?) -> SpriteObject? {
        if !hasObject(sourceObject) {
            return nil
        }
        let context = CBMutableCopyContext()
        var copiedVariablesAndLists = [AnyHashable]() as? [UserVariable]
        
        var variablesAndLists: [UserVariable]? = nil
        if let anObject = variables.objectVariables(for: sourceObject) {
            variablesAndLists = anObject as? [UserVariable]
        }
        if let anObject = variables.objectLists(for: sourceObject) as? [AnyHashable] {
            variablesAndLists?.append(anObject)
        }
        
        for variableOrList: UserVariable? in variablesAndLists ?? [] {
            let copiedVariableOrList = UserVariable(variable: variableOrList)
            
            copiedVariablesAndLists?.append(copiedVariableOrList)
            context.updateReference(variableOrList, withReference: copiedVariableOrList)
        }
        
        let copiedObject = sourceObject?.mutableCopy(with: context) as? SpriteObject
        copiedObject?.name = Util.uniqueName(nameOfCopiedObject, existingNames: allObjectNames())!
        if let anObject = copiedObject {
            objectList.append(anObject)
        }
        
        for variableOrList: UserVariable? in copiedVariablesAndLists ?? [] {
            if variableOrList?.isList ?? false {
                variables.addObjectList(variableOrList, for: copiedObject)
            } else {
                variables.addObjectVariable(variableOrList, for: copiedObject)
            }
        }
        
        saveToDisk(withNotification: true)
        return copiedObject
    }
    
    func isEqual(to program: Program?) -> Bool {
        if !header.isEqual(to: program?.header) {
            return false
        }
        if !variables.isEqual(to: program?.variables) {
            return false
        }
        if objectList.count != program?.objectList.count {
            return false
        }
        
        var idx: Int
        for idx in 0..<objectList.count {
            let firstObject: SpriteObject = objectList[idx]
            var secondObject: SpriteObject? = nil
            
            var programIdx: Int
            for programIdx in 0..<(program?.objectList.count ?? 0) {
                let programObject: SpriteObject? = program?.objectList[programIdx]
                
                if (programObject?.name == firstObject.name) {
                    secondObject = programObject
                    break
                }
            }
            
            if secondObject == nil || !firstObject.isEqual(to: secondObject) {
                return false
            }
        }
        return true
    }
    
    func getRequiredResources() -> Int {
        var resources = ResourceType.noResources
        
        for obj: SpriteObject in objectList {
            resources |= obj.getRequiredResources()
        }
        return resources
        
    }
    
    func defaultProgram(withName programName: String?, programID: String?) -> Program {
        programName = Util.uniqueName(programName, existingNames: self.allProgramNames())
        let program = Program()
        program.header = Header.defaultHeader()
        program.header.programName = programName ?? ""
        program.header.programID = programID ?? ""
        
        let fileManager = CBFileManager.shared()
        if fileManager?.directoryExists(programName) == nil {
            fileManager?.createDirectory(program.projectPath())
        }
        
        let imagesDirName = "\(program.projectPath() ?? "")\(kProgramImagesDirName)"
        if fileManager?.directoryExists(imagesDirName) == nil {
            fileManager?.createDirectory(imagesDirName)
        }
        
        let soundsDirName = "\(program.projectPath() ?? "")\(kProgramSoundsDirName)"
        if fileManager?.directoryExists(soundsDirName) == nil {
            fileManager?.createDirectory(soundsDirName)
        }
        
        program.addObject(withName: kLocalizedBackground)
        print(String(format: "%@", program.description))
        return program
    }
    
    func lastUsed() -> Self {
        return (Program(loadingInfo: Util.lastUsedProgramLoadingInfo()))
    }
    
    func updateLastModificationTimeForProgram(withName programName: String?, programID: String?) {
        let xmlPath = "\(Program.projectPathForProgram(withName: programName, programID: programID) ?? "")\(kProgramCodeFileName)"
        let fileManager = CBFileManager.shared()
        fileManager?.changeModificationDate(Date(), forFileAtPath: xmlPath)
    }
    
    convenience init(loadingInfo: ProgramLoadingInfo?) {
        print(String(format: "Try to load project '%@'", (loadingInfo?.visibleName)!))
        print(String(format: "Path: %@", (loadingInfo?.basePath)!))
        var xmlPath: String? = nil
        if let aPath = loadingInfo?.basePath {
            xmlPath = "\(aPath)\(kProgramCodeFileName)"
        }
        print(String(format: "XML-Path: %@", xmlPath!))
        
        //    //######### FIXME remove that later!! {
        //        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        //        xmlPath = [bundle pathForResource:@"ValidProgramAllBricks093" ofType:@"xml"];
        //    // }
        
        var program: Program? = nil
        let languageVersion = Util.detectCBLanguageVersionFromXML(withPath: xmlPath)
        
        if languageVersion == CGFloat(kCatrobatInvalidVersion) {
            print("Invalid catrobat language version!")
            return
        }
        
        // detect right parser for correct catrobat language version
        let catrobatParser = CBXMLParser(path: xmlPath ?? "")
        if !catrobatParser!.isSupportedLanguageVersion(languageVersion) {
            let parser = Parser()
            program = parser.generateObjectForProgram(withPath: xmlPath)
        } else {
            program = catrobatParser!.parseAndCreateProgram()
        }
        program?.header.programID = loadingInfo?.programID ?? ""
        
        if program == nil {
            return
        }
        
        print(String(format: "%@", (program?.description)!))
        print(String(format: "ProjectResolution: width/height:  %f / %f", Float((program?.header.screenWidth!)!), Float(truncating: (program?.header.screenHeight!)!)))
        self.updateLastModificationTimeForProgram(withName: loadingInfo?.visibleName, programID: loadingInfo?.programID)
    }
    
    func programExists(withProgramName programName: String?, programID: String?) -> Bool {
        let allProgramLoadingInfos = self.allProgramLoadingInfos()
        
        // check if program with same ID already exists
        if programID != nil && (programID?.count ?? 0) != 0 {
            if self.programExists(withProgramID: programID) {
                return true
            }
        }
        
        // no programID match => check if program with same name already exists
        for programLoadingInfo: ProgramLoadingInfo? in allProgramLoadingInfos as? [ProgramLoadingInfo?] ?? [] {
            if (programName == programLoadingInfo?.visibleName) {
                return true
            }
        }
        return false
    }
    
    static func programExists(withProgramID programID: String?) -> Bool {
        let allProgramLoadingInfos = Program.allProgramLoadingInfos()
        for programLoadingInfo: ProgramLoadingInfo? in allProgramLoadingInfos as? [ProgramLoadingInfo?] ?? [] {
            if (programID == programLoadingInfo?.programID) {
                return true
            }
        }
        return false
    }
    
    static func areThereAnyPrograms() -> Bool {
        return Bool(Program.allProgramNames()?.count ?? false)
    }
    
    func copyProgram(withSourceProgramName sourceProgramName: String?, sourceProgramID: String?, destinationProgramName: inout String?) {
        let sourceProgramPath = self.projectPathForProgram(withName: sourceProgramName, programID: sourceProgramID)
        destinationProgramName = Util.uniqueName(destinationProgramName, existingNames: Program.allProgramNames())
        let destinationProgramPath = self.projectPathForProgram(withName: destinationProgramName, programID: nil)
        
        let fileManager = CBFileManager.shared()
        fileManager?.copyExistingDirectory(atPath: sourceProgramPath, toPath: destinationProgramPath)
        let destinationProgramLoadingInfo = ProgramLoadingInfo(forProgramWithName: destinationProgramName, programID: nil)
        let program = Program(loadingInfo: destinationProgramLoadingInfo)
        program.header.programName = destinationProgramLoadingInfo!.visibleName
        program.saveToDisk(withNotification: true)
    }
    
    static func removeProgramFromDisk(withProgramName programName: String?, programID: String?) {
        let fileManager = CBFileManager.shared()
        let projectPath = self.projectPathForProgram(withName: programName, programID: programID)
        if fileManager?.directoryExists(projectPath) != nil {
            fileManager?.deleteDirectory(projectPath)
        }
        
        // if this is currently set as last used program, then look for next program to set it as
        // the last used program
        if self.isLastUsedProgram(programName, programID: programID) {
            Util.setLastProgramWithName(nil, programID: nil)
            let allProgramLoadingInfos = Program.allProgramLoadingInfos()
            for programLoadingInfo: ProgramLoadingInfo? in allProgramLoadingInfos as? [ProgramLoadingInfo?] ?? [] {
                Util.setLastProgramWithName(programLoadingInfo?.visibleName, programID: programLoadingInfo?.programID)
                break
            }
        }
        
        // if there are no programs left, then automatically recreate default program
        fileManager?.addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist()
    }
    
    func isLastUsedProgram(_ programName: String?, programID: String?) -> Bool {
        let lastUsedInfo = Util.lastUsedProgramLoadingInfo()
        let info = ProgramLoadingInfo(forProgramWithName: programName, programID: programID)
        return lastUsedInfo!.isEqual(to: info)
    }
    
    func setLastUsed(_ program: Program?) {
        Util.setLastProgramWithName(program?.header.programName, programID: program?.header.programID)
    }
    
    static func basePath() -> String? {
        return "\(Util.applicationDocumentsDirectory())/\(kProgramsFolder)/"
    }
    
    static func allProgramNames() -> [Any]? {
        let allProgramLoadingInfos = self.allProgramLoadingInfos()
        var programNames = [AnyHashable](repeating: 0, count: allProgramLoadingInfos?.count ?? 0)
        for loadingInfo: ProgramLoadingInfo? in allProgramLoadingInfos as? [ProgramLoadingInfo?] ?? [] {
            if let aName = loadingInfo?.visibleName {
                programNames.append(aName)
            }
        }
        return programNames
    }
    
    static func allProgramLoadingInfos() -> [Any]? {
        let basePath = Program.basePath()
        var error: Error?
        var subdirNames = try? FileManager.default.contentsOfDirectory(atPath: basePath ?? "")
        // TODO: CONVERT NSLogError(error)
        subdirNames = (subdirNames as NSArray?)?.sortedArray(using: #selector(localizedCaseInsensitiveCompare(_:))) as? [String]
        
        var programLoadingInfos = [AnyHashable](repeating: 0, count: subdirNames?.count ?? 0)
        for subdirName: String? in subdirNames ?? [] {
            // exclude .DS_Store folder on MACOSX simulator
            if (subdirName == ".DS_Store") {
                continue
            }
            
            let info: ProgramLoadingInfo? = self.programLoadingInfo(forProgramDirectoryName: subdirName)
            if info == nil {
                print(String(format: "Unable to load program located in directory %@", subdirName))
                continue
            }
            print(String(format: "Adding loaded program: %@", info?.basePath))
            if let anInfo = info {
                programLoadingInfos.append(anInfo)
            }
        }
        return programLoadingInfos
    }
    
    static func programDirectoryName(forProgramName programName: String?, programID: String?) -> String? {
        return "\(programName ?? "")\(kProgramIDSeparator)\((programID != nil ? programID : kNoProgramIDYetPlaceholder) ?? "")"
    }
    
    static func programLoadingInfo(forProgramDirectoryName directoryName: String?) -> ProgramLoadingInfo? {
        // TODO: CONVERT CBAssert(directoryName)
        let directoryNameParts = directoryName?.components(separatedBy: kProgramIDSeparator)
        if (directoryNameParts?.count ?? 0) < 2 {
            return nil
        }
        let programID = directoryNameParts?.last as? String
        let programName = (directoryName as? NSString)?.substring(to: (directoryName?.count ?? 0) - (programID?.count ?? 0) - 1)
        return ProgramLoadingInfo(name: programName, programID: programID)
    }
    
    static func programName(forProgramID programID: String?) -> String? {
        if (!(programID ?? "")) != "" || (!(programID?.count ?? 0)) != 0 {
            return nil
        }
        let allProgramLoadingInfos = self.allProgramLoadingInfos()
        for programLoadingInfo: ProgramLoadingInfo? in allProgramLoadingInfos as? [ProgramLoadingInfo?] ?? [] {
            if (programLoadingInfo?.programID == programID) {
                return programLoadingInfo?.visibleName
            }
        }
        return nil
    }
    
    // MARK: - factories
    
    func objectExists(withName objectName: String?) -> Bool {
        for object: SpriteObject in objectList {
            if (object.name == objectName) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Custom getter and setter
    
    static func projectPathForProgram(withName programName: String?, programID: String?) -> String? {
        return "\(Program.basePath() ?? "")\(self.programDirectoryName(forProgramName: Util.replaceBlockedCharacters(for: programName), programID: programID) ?? "")/"
    }
    
    // MARK: - helpers
    
    func description() -> String {
        var ret = ""
        ret += "\n----------------- PROGRAM --------------------\n"
        ret += "Application Build Name: \(header.applicationBuildName)\n"
        ret += "Application Build Number: \(header.applicationBuildNumber)\n"
        ret += "Application Name: \(header.applicationName)\n"
        ret += "Application Version: \(header.applicationVersion)\n"
        ret += "Catrobat Language Version: \(header.catrobatLanguageVersion)\n"
        if let anUpload = header.dateTimeUpload {
            ret += "Date Time Upload: \(anUpload)\n"
        }
        ret += "Description: \(header._description)\n"
        ret += "Device Name: \(header.deviceName)\n"
        ret += "Media License: \(header.mediaLicense)\n"
        ret += "Platform: \(header.platform)\n"
        ret += "Platform Version: \(header.platformVersion)\n"
        ret += "Program License: \(header.programLicense)\n"
        ret += "Program Name: \(header.programName)\n"
        ret += "Remix of: \(header.remixOf)\n"
        if let aHeight = header.screenHeight {
            ret += "Screen Height: \(aHeight)\n"
        }
        if let aWidth = header.screenWidth {
            ret += "Screen Width: \(aWidth)\n"
        }
        ret += "Screen Mode: \(header.screenMode)\n"
        ret += "Sprite List: \(objectList)\n"
        ret += "URL: \(header.url)\n"
        ret += "User Handle: \(header.userHandle)\n"
        ret += "Variables: \(variables)\n"
        ret += "------------------------------------------------\n"
        return ret
    }
    // returns true if either same programID and/or same programName already exists    // returns true if either same programID and/or same programName already exists
}
