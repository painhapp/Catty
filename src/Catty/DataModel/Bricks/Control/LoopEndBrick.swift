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

class LoopEndBrick: Brick {
    weak var loopBeginBrick: LoopBeginBrick?
    var loopEndTime: Date?
    
    override func isSelectableForObject() -> Bool {
        return false
    }
    
    override func isAnimateable() -> Bool {
        return true
    }
    
    override func isLoopBrick() -> Bool {
        return true
    }
    
    func brickTitle() -> String? {
        return kLocalizedEndOfLoop
    }
    
    override func perform(from script: Script?) {
        print(String(format: "Performing: %@", description))
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "EndLoop"
    }
    
    // MARK: - Compare
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(Util.isEqual(loopBeginBrick?.brickTitle, to: ((brick as? LoopEndBrick)?.loopBeginBrick)?.brickTitle)) {
            return false
        }
        return true
    }
    
    // MARK: - Copy
    
    override func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        let brick = mutableCopy(with: context, andErrorReporting: false) as? LoopEndBrick
        let beginBrick: (LoopBeginBrick & CBConditionProtocol)? = context?.updatedReference(forReference: loopBeginBrick) as! (LoopBeginBrick & CBConditionProtocol)
        
        if beginBrick != nil {
            brick?.loopBeginBrick = beginBrick
            beginBrick?.loopEndBrick = brick
        } else {
            // TODO: CONVERT NSError("LoopBeginBrick must not be nil for Brick with class %@!", LoopEndBrick)
        }
        return brick
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.noResources
    }
}
