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

import SpriteKit

class SpriteObject: NSObject, CBMutableCopying {
    var name = ""
    
    private var _lookList: [Look] = []
    var lookList: [Look] {
        // lazy instantiation
        if !_lookList {
            _lookList = []
        }
        return _lookList
    }
    
    private var _soundList: [Sound] = []
    var soundList: [Sound] {
        // lazy instantiation
        #if false
        if !_soundList {
            _soundList = []
        }
        #endif
        return _soundList
    }
    
    private var _scriptList: [Script] = []
    var scriptList: [Script] {
        // lazy instantiation
        #if false
        if !_scriptList {
            if let anArray = [AnyHashable]() as? [Script] {
                _scriptList = anArray
            }
        }
        #endif
        return _scriptList
    }
    weak var program: Program?
    weak var spriteNode: CBSpriteNode?
    
    func numberOfScripts() -> Int {
        return scriptList.count
    }
    
    func numberOfTotalBricks() -> Int {
        return numberOfScripts() + numberOfNormalBricks()
    } // including script bricks
    
    func numberOfNormalBricks() -> Int {
        var numberOfBricks: Int = 0
        for script: Script in scriptList {
            numberOfBricks += script.brickList.count
        }
        return numberOfBricks
    } // excluding script bricks
    
    func numberOfLooks() -> Int {
        return lookList.count
    }
    
    func numberOfSounds() -> Int {
        return soundList.count
    }
    
    func isBackground() -> Bool {
        if program != nil && program?.objectList.count != nil {
            return program?.objectList[0] == self
        }
        return false
    }

    // helpers
    
    func projectPath() -> String? {
        return program?.projectPath()
    } //for image-path!!!
    
    func previewImagePathForLook(at index: Int) -> String? {
        if index >= lookList.count {
            return nil
        }
        
        let look: Look = lookList[index]
        #if false
        if !look {
            return nil
        }
        #endif
        
        let imageDirPath = projectPath() ?? "" + (kProgramImagesDirName)
        return "\(imageDirPath)/\(look.previewImageFileName() ?? "")"
    }
    
    func previewImagePath() -> String? {
        return previewImagePathForLook(at: 0)
    } // thumbnail/preview image-path of first (!) look shown in several TableViewCells!!!
    
    func path(for look: Look?) -> String? {
        return "\(projectPath() ?? "")\(kProgramImagesDirName)/\(look?.fileName ?? "")"
    }
    
    func path(for sound: Sound?) -> String? {
        return "\(projectPath() ?? "")\(kProgramSoundsDirName)/\(sound?.fileName ?? "")"
    }
    
    func fileSizeOf(_ look: Look?) -> Int {
        let path = self.path(for: look)
        let fileManager = CBFileManager.shared()
        return Int(fileManager?.sizeOfFile(atPath: path) ?? 0)
    }
    
    func dimensionsOf(_ look: Look?) -> CGSize {
        let path = self.path(for: look)
        // very fast implementation! far more quicker than UIImage's size method/property
        return path?.sizeOfImageForFilePath() ?? CGSize.zero
    }
    
    func fileSizeOf(_ sound: Sound?) -> Int {
        let path = self.path(for: sound)
        let fileManager = CBFileManager.shared()
        return Int(fileManager?.sizeOfFile(atPath: path) ?? 0)
    }
    
    func durationOf(_ sound: Sound?) -> CGFloat {
        let path = self.path(for: sound)
        return AudioManager.shared().durationOfSound(withFilePath: path)
    }
    
    func allLookNames() -> [Any]? {
        var lookNames = [AnyHashable](repeating: 0, count: lookList.count)
        for look: Any in lookList {
            if (look is Look) {
                lookNames.append((look as? Look)?.name ?? "")
            }
        }
        return lookNames
    }
    
    func allSoundNames() -> [Any]? {
        var soundNames = [AnyHashable](repeating: 0, count: soundList.count)
        for sound: Any in soundList {
            if (sound is Sound) {
                soundNames.append((sound as? Sound)?.name ?? "")
            }
        }
        return soundNames
    }
    
    func referenceCount(forLook fileName: String?) -> Int {
        var referenceCount: Int = 0
        for object: SpriteObject? in program?.objectList ?? [] {
            for look: Look? in object?.lookList ?? [] {
                if (look?.fileName == fileName) {
                    referenceCount += 1
                }
            }
        }
        return referenceCount
    }
    
    func referenceCount(forSound fileName: String?) -> Int {
        var referenceCount: Int = 0
        for object: SpriteObject? in program?.objectList ?? [] {
            for sound: Sound? in object?.soundList ?? [] {
                if (sound?.fileName == fileName) {
                    referenceCount += 1
                }
            }
        }
        return referenceCount
    }

    // actions
    
    func add(_ look: Look?, andSaveToDisk save: Bool) {
        if hasLook(look) {
            return
        }
        look?.name = Util.uniqueName(look?.name, existingNames: allLookNames())!
        _lookList.append(look!) //TODO: Check
        if save {
            program?.saveToDisk(withNotification: true)
        }
        return
    }
    
    func removeFromProgram() {
        // TODO: Convert CBAssert(program)
        var index: Int = 0
        for spriteObject: SpriteObject? in program?.objectList ?? [] {
            if spriteObject == self {
                program?.objectList.remove(at: index)
                program = nil
                break
            }
            index += 1
        }
    }
    
    func removeLooks(_ looks: [Look], andSaveToDisk save: Bool) {
        if looks == lookList {
            looks = looks
        }
        for look: Any? in looks ?? [] {
            if (look is Look) {
                removeLook(fromList: look as? Look)
            }
        }
        if save {
            program?.saveToDisk(withNotification: true)
        }
    }
    
    func remove(_ look: Look?, andSaveToDisk save: Bool) {
        removeLook(fromList: look)
        if save {
            program?.saveToDisk(withNotification: true)
        }
    }
    
    func removeSounds(_ sounds: [Sound], andSaveToDisk save: Bool) {
        if sounds == soundList {
            sounds = sounds
        }
        for sound: Any? in sounds ?? [] {
            if (sound is Sound) {
                removeSound(fromList: sound as? Sound)
            }
        }
        if save {
            program?.saveToDisk(withNotification: true)
        }
    }
    
    func remove(_ sound: Sound?, andSaveToDisk save: Bool) {
        removeSound(fromList: sound)
        if save {
            program?.saveToDisk(withNotification: true)
        }
    }
    
    func renameLook(_ look: Look?, toName newLookName: String?, andSaveToDisk save: Bool) {
        if !hasLook(look) || (look?.name == newLookName) {
            return
        }
        look?.name = Util.uniqueName(newLookName, existingNames: allLookNames())!
        if save {
            program?.saveToDisk(withNotification: true)
        }
    }
    
    func renameSound(_ sound: Sound?, toName newSoundName: String?, andSaveToDisk save: Bool) {
        if !hasSound(sound) || (sound?.name == newSoundName) {
            return
        }
        sound?.name = Util.uniqueName(newSoundName, existingNames: allSoundNames())
        if save {
            program?.saveToDisk(withNotification: true)
        }
    }
    
    func hasLook(_ look: Look?) -> Bool {
        if let aLook = look {
            return lookList.contains(aLook)
        }
        return false
    }
    
    func hasSound(_ sound: Sound?) -> Bool {
        if let aSound = sound {
            return soundList.contains(aSound)
        }
        return false
    }
    
    func copy(_ sourceLook: Look?, withNameForCopiedLook nameOfCopiedLook: String?, andSaveToDisk save: Bool) -> Look? {
        if !hasLook(sourceLook) {
            return nil
        }
        let copiedLook = sourceLook?.mutableCopy(with: CBMutableCopyContext()) as? Look
        copiedLook?.name = Util.uniqueName(nameOfCopiedLook, existingNames: allLookNames())!
        if let aLook = copiedLook {
            _lookList.append(aLook)
        }
        if save {
            program?.saveToDisk(withNotification: true)
        }
        return copiedLook
    }
    
    func removeLook(fromList look: Look?) {
        // do not use NSArray's removeObject here
        // => if isEqual is overriden this would lead to wrong results
        var index: Int = 0
        for currentLook: Look in lookList {
            if currentLook != look {
                index += 1
                continue
            }
            
            // count references in all object of that look image
            let lookImageReferenceCounter: Int = referenceCount(forLook: look?.fileName)
            // if image is not used by other objects, delete it
            if lookImageReferenceCounter <= 1 {
                let fileManager = CBFileManager.shared()
                fileManager?.deleteFile(previewImagePathForLook(at: index))
                fileManager?.deleteFile(path(for: look))
            }
            _lookList.remove(at: index)
            break
        }
    }
    
    func removeSound(fromList sound: Sound?) {
        // do not use NSArray's removeObject here
        // => if isEqual is overriden this would lead to wrong results
        var index: Int = 0
        for currentSound: Sound in soundList {
            if currentSound != sound {
                index += 1
                continue
            }
            
            // count references in all object of that sound file
            let soundReferenceCounter: Int = referenceCount(forSound: sound?.fileName)
            // if sound is not used by other objects, delete it
            if soundReferenceCounter <= 1 {
                let fileManager = CBFileManager.shared()
                fileManager?.deleteFile(path(for: sound))
            }
            _soundList.remove(at: index)
            break
        }
    }
    
    func copy(_ sourceSound: Sound?, withNameForCopiedSound nameOfCopiedSound: String?, andSaveToDisk save: Bool) -> Sound? {
        if !hasSound(sourceSound) {
            return nil
        }
        let copiedSound = sourceSound?.mutableCopy(with: CBMutableCopyContext()) as? Sound
        copiedSound?.name = Util.uniqueName(nameOfCopiedSound, existingNames: allSoundNames())
        if let aSound = copiedSound {
            _soundList.append(aSound)
        }
        if save {
            program?.saveToDisk(withNotification: true)
        }
        return copiedSound
    }
    
    @objc func removeReferences() {
        program = nil
        _scriptList.makeObjectsPerform(#selector(SpriteObject.removeReferences))
    }
    
    func description() -> String {
        var mutableString = ""
        mutableString += "Name: \(name)\r"
        mutableString += "Scripts: \(scriptList)\r"
        mutableString += "Looks: \(lookList)\r"
        mutableString += "Sounds: \(soundList)\r"
        return mutableString
    }
    
    // MARK: - Compare
    
    func isEqual(to spriteObject: SpriteObject?) -> Bool {
        // check if object names are both equal to each other
        if !(name == spriteObject?.name) {
            return false
        }
        
        // lookList
        if lookList.count != spriteObject?.lookList.count {
            return false
        }
        
        var index: Int
        for index in 0..<lookList.count {
            let firstLook: Look = lookList[index]
            let secondLook: Look? = spriteObject?.lookList[index]
            
            if !firstLook.isEqual(to: secondLook) {
                return false
            }
        }
        
        // soundList
        if soundList.count != spriteObject?.soundList.count {
            return false
        }
        
        for index in 0..<soundList.count {
            let firstSound: Sound = soundList[index]
            let secondSound: Sound? = spriteObject?.soundList[index]
            
            if !firstSound.isEqual(to: secondSound) {
                return false
            }
        }
        
        // scriptList
        if scriptList.count != spriteObject?.scriptList.count {
            return false
        }
        for index in 0..<scriptList.count {
            let firstScript: Script = scriptList[index]
            let secondScript: Script? = spriteObject?.scriptList[index]
            
            if !firstScript.isEqual(to: secondScript) {
                return false
            }
        }
        return true
    }
    
    // MARK: - Copy
    
    func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        if context == nil {
            // TODO: CONVERT NSError("%@ must not be nil!", CBMutableCopyContext.self)
        }
        
        let newObject = SpriteObject()
        newObject.name = name
        newObject.program = program
        context?.updateReference(self, withReference: newObject)
        
        // deep copy
        if let aCount = [AnyHashable](repeating: 0, count: lookList.count) as? [Look] {
            newObject.lookList = aCount
        }
        for lookObject: Any in lookList {
            if (lookObject is Look) {
                if let aContext = lookObject.mutableCopy(with: context) {
                    newObject.lookList.append(aContext)
                }
            }
        }
        if let aCount = [AnyHashable](repeating: 0, count: soundList.count) as? [Sound] {
            newObject.soundList = aCount
        }
        for soundObject: Any in soundList {
            if (soundObject is Sound) {
                if let aContext = soundObject.mutableCopy(with: context) {
                    newObject.soundList.append(aContext)
                }
            }
        }
        if let aCount = [AnyHashable](repeating: 0, count: scriptList.count) as? [Script] {
            newObject.scriptList = aCount
        }
        for scriptObject: Any in scriptList {
            if (scriptObject is Script) {
                let copiedScript = scriptObject.mutableCopy(with: context) as? Script
                copiedScript?.object = newObject
                if let aScript = copiedScript {
                    newObject.scriptList.append(aScript)
                }
            }
        }
        return newObject
    }
    
    func getRequiredResources() -> Int {
        var resources = ResourceType.noResources
        
        for script: Script in scriptList {
            resources = resources | script.getRequiredResources()
        }
        return resources
    }
    
    // MARK: - Helpers
}
