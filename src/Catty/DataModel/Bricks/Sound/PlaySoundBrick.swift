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

class PlaySoundBrick: Brick, BrickSoundProtocol {
    var sound: Sound?
    
    func brickTitle() -> String? {
        return kLocalizedPlaySound + ("\n%@")
    }
    
    // MARK: - Copy
    
    override func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        if context == nil {
            // TODO: CONVERT NSError("%@ must not be nil!", CBMutableCopyContext.self)
        }
        let brick = PlaySoundBrick()
        brick.sound = sound
        context?.updateReference(self, withReference: brick)
        
        return brick
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "PlaySound (File Name: \(sound?.fileName ?? ""))"
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(sound?.isEqual(to: (brick as? PlaySoundBrick)?.sound) ?? false) {
            return false
        }
        return true
    }
    
    func setSound(_ sound: Sound?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if sound != nil {
            self.sound = sound
        }
    }
    
    func sound(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Sound? {
        return sound
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        if spriteObject != nil {
            let sounds = spriteObject?.soundList
            if (sounds?.count ?? 0) > 0 {
                sound = sounds?[0]
            } else {
                sound = nil
            }
        }
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.noResources
    }
}
