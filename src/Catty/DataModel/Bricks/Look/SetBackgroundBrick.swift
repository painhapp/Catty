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

class SetBackgroundBrick: Brick, BrickLookProtocol {
    var look: Look?
    
    func pathForLook() -> String? {
        return "\(script?.object?.projectPath() ?? "")\(kProgramImagesDirName)/\(look?.fileName ?? "")"
    }
    
    func brickTitle() -> String? {
        return kLocalizedSetBackground + ("\n%@")
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "SetBackgroundBrick (Background: \(look?.name ?? ""))"
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if look?.isEqual(to: (brick as? SetBackgroundBrick)?.look) ?? false {
            return true
        }
        return false
    }
    
    func look(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Look? {
        return look
    }
    
    func setLook(_ look: Look?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if look != nil {
            self.look = look
        }
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        if spriteObject != nil {
            let looks = spriteObject?.lookList
            if (looks?.count ?? 0) > 0 {
                look = looks?[0]
            } else {
                look = nil
            }
        }
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.noResources
    }
    
    override func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        if context == nil {
            // TODO: CONVERT NSError("%@ must not be nil!", CBMutableCopyContext.self)
        }
        let brick = SetBackgroundBrick()
        brick.look = look
        context?.updateReference(self, withReference: brick)
        
        return brick
    }
}
