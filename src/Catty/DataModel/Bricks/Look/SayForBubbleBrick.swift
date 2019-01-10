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

class SayForBubbleBrick: Brick, BrickFormulaProtocol {
    var stringFormula: Formula?
    var intFormula: Formula?
    
    override init() {
        super.init()
    }
    
    func brickTitle() -> String? {
        let localizedSecond = intFormula?.isSingularNumber() ?? false ? kLocalizedSecond : kLocalizedSeconds
        return kLocalizedSay + ("%@\n") + (kLocalizedFor) + ("%@") + (localizedSecond)
    }
    
    func allowsStringFormula() -> Bool {
        return true
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        stringFormula = Formula(string: kLocalizedHello)
        intFormula = Formula(integer: 1)
    }
    
    override func isDisabledForBackground() -> Bool {
        return true
    }
    
    // MARK: - Description
    
    override func description() -> String {
        if let aFormula = stringFormula, let aFormula1 = intFormula {
            return "Say: \(aFormula) for \(aFormula1) seconds"
        }
        return ""
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if formula != nil {
            if lineNumber == 1 {
                intFormula = formula
            } else {
                stringFormula = formula
            }
        }
    }
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        return lineNumber == 1 ? intFormula : stringFormula
    }
    
    func getFormulas() -> [Formula]? {
        return [stringFormula!, intFormula!]
    }
}
