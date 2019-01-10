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

import UIKit

class Brick: NSObject, BrickProtocol {
    var brickCategoryType: BrickCategoryType?
    var brickType: BrickType?
    private(set) var brickTitle = ""
    weak var script: Script?
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
    
    func isFormulaBrick() -> Bool {
        return self is BrickFormulaProtocol
    }
    
    func isDisabledForBackground() -> Bool {
        return false
    }
    
    func isBluetoothBrick() -> Bool {
        return false
    }
    
    func isPhiroBrick() -> Bool {
        return false
    }
    
    func isArduinoBrick() -> Bool {
        return false
    }
    
    func brickTitle(forBrickinSelection inSelection: Bool, inBackground: Bool) -> String? {
        return brickTitle
    }
    
    func description() -> String {
        // TODO: CONVERT NSERROR
        return "Brick (NO SPECIFIC DESCRIPTION GIVEN! OVERRIDE THE DESCRIPTION METHOD!)"
    }
    
    func isEqual(to brick: Brick?) -> Bool {
        if brickCategoryType != brick?.brickCategoryType {
            return false
        }
        if brickType != brick?.brickType {
            return false
        }
        
        let firstPropertyList = Util.propertiesOfInstance(self).allValues
        let secondPropertyList = Util.propertiesOfInstance(brick).allValues
        
        if firstPropertyList.count != secondPropertyList.count {
            return false
        }
        
        var index: Int
        for index in 0..<firstPropertyList.count {
            let firstObject = firstPropertyList[index] as NSObject
            let secondObject = secondPropertyList[index] as NSObject
            
            // prevent recursion (e.g. Script->Brick->Script->Brick...)
            if (firstObject is Script) && (secondObject is Script) {
                continue
            }
            
            if !Util.isEqual(firstObject, to: secondObject) {
                return false
            }
        }
        
        return true
    }
    
    func mutableCopy(with context: CBMutableCopyContext?, andErrorReporting reportError: Bool) -> Any? {
        if context == nil {
            // TODO: CONVERT NSError("%@ must not be nil!", CBMutableCopyContext.self)
        }
        var brick = Brick()
        brick.brickCategoryType = brickCategoryType
        brick.brickType = brickType
        context?.updateReference(self, withReference: brick)
        
        let properties = Util.properties(ofInstance: self)
        for propertyKey: String in properties as? [String] ?? [:] {
            let propertyValue = properties[propertyKey]
            let propertyClazz = propertyValue.self
            if propertyValue is CBMutableCopying != nil {
                let updatedReference = context?.updatedReference(forReference: propertyValue)
                if updatedReference != nil {
                    brick.setValue(updatedReference, forKey: propertyKey)
                } else {
                    let propertyValueClone = propertyValue?.mutableCopy(with: context)
                    brick.setValue(propertyValueClone, forKey: propertyKey)
                }
            } else if propertyValue is NSMutableCopying != nil {
                // standard datatypes like NSString are already conforming to the NSMutableCopying protocol
                let propertyValueClone = propertyValue?.mutableCopy(with: nil)
                brick.setValue(propertyValueClone, forKey: propertyKey)
            } else if BooleanLiteralConvertible(propertyClazz ?? false) == true.self {
                // 64-bit bool -> typedef bool BOOL
                brick.setValue(propertyValue, forKey: propertyKey)
            } else if IntegerLiteralConvertible(propertyClazz ?? 0) == 1.self {
                // 32-bit bool -> typedef signed char BOOL
                brick.setValue(propertyValue, forKey: propertyKey)
            } else if reportError {
                // TODO: CONVERT NSError("Property %@ of class %@ in Brick of class %@ does not conform to CBMutableCopying protocol. Implement mutableCopyWithContext method in %@", propertyKey, propertyValue.self, Brick, Brick)
            }
        }
        return brick
    }
    
    @objc func removeFromScript() {
        var index: Int = 0
        for brick: Brick? in script?.brickList ?? [] {
            if brick == self {
                script?.brickList.remove(at: index)
                break
            }
            index += 1
        }
    }
    
    @objc func removeReferences() {
        script = nil
    }
    
    func getRequiredResources() -> Int {
        //OVERRIDE IN EVERY BRICK
        let resources = ResourceType.noResources
        
        return resources
    }
    
    // MARK: - NSObject
    
    override init() {
        super.init()
        
        let subclassName = NSStringFromClass(Brick.self)
        let brickManager = BrickManager.shared()
        brickType = BrickType(rawValue: brickManager!.brickType(forClassName: subclassName))
        brickCategoryType = BrickCategoryType(rawValue: brickManager!.brickCategoryType(forBrickType: brickType!.rawValue))
    }
    
    func isIfLogicBrick() -> Bool {
        return false
    }
    
    func isLoopBrick() -> Bool {
        return false
    }
    
    func perform(from script: Script?) throws {
        // TODO: CONVERT throw NSException(name: .internalInconsistencyException, reason: "You must override \(NSStringFromSelector(#function)) in a subclass", userInfo: nil)
    }
    
    func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        // Override this method in Brick implementation
    }
    
    // MARK: - Copy
    // This function must be overriden by Bricks with references to other Bricks (e.g. ForeverBrick)
    
    func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        return mutableCopy(with: context, andErrorReporting: true) as! Brick
    }
}
