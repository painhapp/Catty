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

class IfThenLogicBeginBrick: Brick, BrickFormulaProtocol {
    var ifCondition: Formula?
    weak var ifEndBrick: IfThenLogicEndBrick?
    
    override func isAnimateable() -> Bool {
        return true
    }
    
    override func isIfLogicBrick() -> Bool {
        return true
    }
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        return ifCondition
    }
    
    func getFormulas() -> [Formula]? {
        return [ifCondition!]
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        ifCondition = formula
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        ifCondition = Formula(integer: 1)
    }
    
    func brickTitle() -> String? {
        return kLocalizedIfBegin + ("%@ " + (kLocalizedIfBeginSecondPart))
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "If Then Logic Begin Brick"
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(Util.isEqual(ifEndBrick?.brickTitle(), to: (brick as? IfThenLogicBeginBrick)?.ifEndBrick?.brickTitle())) {
            return false
        }
        if !(ifCondition?.isEqual(to: (brick as? IfThenLogicBeginBrick)?.ifCondition) ?? false) {
            return false
        }
        return true
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return ifCondition?.getRequiredResources() ?? 0
    }
}
