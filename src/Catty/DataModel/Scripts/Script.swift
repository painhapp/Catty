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
import UIKit

class Script: NSObject, ScriptProtocol, CBMutableCopying {
    private(set) var brickCategoryType: BrickCategoryType?
    private(set) var brickType: BrickType?
    
    var brickTitle: String {
        throw NSException(name: .internalInconsistencyException, reason: "You must override \(NSStringFromSelector(#function)) in the subclass \(NSStringFromClass(Script.self))", userInfo: nil)
    }
    weak var object: SpriteObject?
    
    private var _brickList: [Brick] = []
    var brickList: [Brick] {
        #if false
        if !_brickList {
            if let anArray = [AnyHashable]() as? [Brick] {
                _brickList = anArray
            }
        }
        #endif
        return _brickList
    }
    var animate = false
    var animateInsertBrick = false
    var animateMoveBrick = false
    var isSelected = false
    
    func isSelectableForObject() -> Bool {
        return true
    }
    
    func isAnimateable() -> Bool {
        return false
    }
    
    func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        // Override this method in Script implementation
    }
    
    func add(_ brick: Brick?, at index: Int) {
        if let aBrick = brick {
            // TODO: CONVERT CBAssert((brickList as NSArray).index(of: aBrick) == NSNotFound)
        }
        brick?.script = self
        if let aBrick = brick {
            brick?.script?.brickList.insert(aBrick, at: index)
        }
    }
    
    func description() -> String {
        var ret = NSStringFromClass(Script.self)
        let clipLength: Int = 8
        var shortObjectName = object?.name
        if object?.name.count > clipLength {
            shortObjectName = "\((shortObjectName as? NSString)?.substring(to: clipLength) ?? "")..."
        }
        ret += String(format: ",object:\"%@\",#bricks:%lu", shortObjectName ?? "", UInt(brickList.count))
        return ret
    }
    
    func isEqual(to script: Script?) -> Bool {
        if brickCategoryType != script?.brickCategoryType {
            return false
        }
        if brickType != script?.brickType {
            return false
        }
        if !Util.isEqual(brickTitle, to: script?.brickTitle) {
            return false
        }
        if (self is WhenScript) {
            if !(script is WhenScript) {
                return false
            }
            if !(Util.isEqual((self as? WhenScript)?.action, to: (script as? WhenScript)?.action)) {
                return false
            }
        }
        if !Util.isEqual(object?.name, to: script?.object?.name) {
            return false
        }
        if brickList.count != script?.brickList.count {
            return false
        }
        
        var index: Int
        for index in 0..<brickList.count {
            let firstBrick: Brick = brickList[index]
            let secondBrick: Brick? = script?.brickList[index]
            
            if !firstBrick.isEqual(to: secondBrick) {
                return false
            }
        }
        return true
    }
    
    func removeFromObject() {
        let index: Int = 0
        for script: Script? in object?.scriptList ?? [] {
            if script == self {
                brickList.makeObjectsPerform(#selector(Script.removeFromScript))
                object?.scriptList.remove(at: index)
                object = nil
                break
            }
            index += 1
        }
    }
    
    @objc func removeReferences() {
        // DO NOT CHANGE ORDER HERE!
        brickList.makeObjectsPerform(#selector(Script.removeReferences))
        object = nil
    }
    
    func getRequiredResources() -> Int {
        var resources = ResourceType.noResources
        
        for brick: Brick in brickList {
            resources |= brick.getRequiredResources()
        }
        return resources
    }
    
    override init() {
        //if super.init()
        
        let subclassName = NSStringFromClass(Script.self)
        let brickManager = BrickManager.shared()
        brickType = BrickType(rawValue: brickManager!.brickType(forClassName: subclassName))
        brickCategoryType = brickManager!.brickCategoryType(forBrickType: brickType)
        
    }
    
    // MARK: - Getters and Setters
    
    // MARK: - Custom getter and setter
    
    func brickTitle(forBrickinSelection inSelection: Bool, inBackground: Bool) -> String? {
        return brickTitle
    }
    
    deinit {
        print(String(format: "Dealloc %@", Script))
    }
    
    // MARK: - Copy
    
    func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        if context == nil {
            // TODO: CONVERT NSError("%@ must not be nil!", CBMutableCopyContext.self)
        }
        
        let copiedScript = Script()
        copiedScript.brickCategoryType = brickCategoryType
        copiedScript.brickType = brickType
        if (self is WhenScript) {
            // TODO: CONVERT CBAssert((copiedScript is WhenScript))
            let whenScript = self as? WhenScript
            (copiedScript as? WhenScript)?.action = whenScript?.action ?? ""
        }
        
        context?.updateReference(self, withReference: copiedScript)
        
        // deep copy
        if let aCount = [AnyHashable](repeating: 0, count: brickList.count) as? [Brick] {
            copiedScript.brickList = aCount
        }
        for brick: Any in brickList {
            if (brick is Brick) {
                let copiedBrick = brick.mutableCopy(with: context) as? Brick // there are some bricks that refer to other sound, look, sprite objects...
                copiedBrick?.script = copiedScript
                if let aBrick = copiedBrick {
                    copiedScript.brickList.append(aBrick)
                }
            }
        }
        if (self is BroadcastScript) {
            (copiedScript as? BroadcastScript)?.receivedMessage = (self as? BroadcastScript)?.receivedMessage ?? ""
        }
        return copiedScript
    }
    
    // MARK: - Description
    
    // MARK: - isEqualToScript
    
    func isDisabledForBackground() -> Bool {
        return false
    }
}
