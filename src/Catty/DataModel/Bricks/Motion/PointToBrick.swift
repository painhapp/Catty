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

class PointToBrick: Brick, BrickObjectProtocol {
    private weak var _pointedObject: SpriteObject?
    weak var pointedObject: SpriteObject? {
        if _pointedObject == nil {
            _pointedObject = script?.object
        }
        return _pointedObject
    }
    
    func brickTitle() -> String? {
        return kLocalizedPointTowards + ("\n%@")
    }
    
    // MARK: - Description
    
    override func description() -> String {
        if let anObject = pointedObject {
            return "Point To Brick: \(anObject)"
        }
        return ""
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(pointedObject?.name == ((brick as? PointToBrick)?.pointedObject)?.name) {
            return false
        }
        return true
    }
    
    // MARK: - BrickObjectProtocol
    
    func setObject(_ object: SpriteObject?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if object != nil {
            _pointedObject = object
        }
    }
    
    func object(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> SpriteObject? {
        return pointedObject
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        if spriteObject != nil {
            var firstObject: SpriteObject? = nil
            for object: SpriteObject? in spriteObject?.program?.objectList ?? [] {
                if !(object?.name == spriteObject?.name) && !(object?.name == kLocalizedBackground) {
                    firstObject = object
                    break
                }
            }
            if firstObject != nil {
                _pointedObject = firstObject
            } else {
                _pointedObject = nil
            }
        }
    }
    
    // MARK: - Copy
    
    override func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        let copy = super.mutableCopy(with: context) as? PointToBrick
        if pointedObject != nil {
            copy?._pointedObject = pointedObject
        }
        return copy
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.noResources
    }
}
