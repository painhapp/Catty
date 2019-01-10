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

class IfLogicElseBrick: Brick {
    weak var ifBeginBrick: IfLogicBeginBrick?
    weak var ifEndBrick: IfLogicEndBrick?
    
    override func isSelectableForObject() -> Bool {
        return false
    }
    
    override func isAnimateable() -> Bool {
        return true
    }
    
    override func isIfLogicBrick() -> Bool {
        return true
    }
    
    func brickTitle() -> String? {
        return kLocalizedElse
    }
    
    override func perform(from script: Script?) {
        print(String(format: "Performing: %@", description))
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "If Logic Else Brick"
    }
    
    // MARK: - Compare
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(Util.isEqual(ifBeginBrick?.brickTitle(), to: (brick as? IfLogicElseBrick)?.ifBeginBrick?.brickTitle())) {
            return false
        }
        if !(Util.isEqual(ifEndBrick?.brickTitle(), to: (brick as? IfLogicElseBrick)?.ifEndBrick?.brickTitle())) {
            return false
        }
        return true
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ResourceType.noResources
    }
}
