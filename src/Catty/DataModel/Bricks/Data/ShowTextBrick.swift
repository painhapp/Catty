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

class ShowTextBrick: Brick, BrickFormulaProtocol, BrickVariableProtocol {
    var userVariable: UserVariable?
    var xFormula: Formula?
    var yFormula: Formula?
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        if paramNumber == 0 {
            return xFormula
        } else if paramNumber == 1 {
            return yFormula
        }
        
        return nil
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if paramNumber == 0 {
            xFormula = formula
        } else if paramNumber == 1 {
            yFormula = formula
        }
    }
    
    func variable(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> UserVariable? {
        return userVariable
    }
    
    func setVariable(_ variable: UserVariable?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        userVariable = variable
    }
    
    func getFormulas() -> [Formula]? {
        return [xFormula!, yFormula!]
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        xFormula = Formula(integer: 100)
        yFormula = Formula(integer: 200)
        if spriteObject != nil {
            let variables = spriteObject?.program?.variables.allVariables(for: spriteObject)
            if (variables?.count ?? 0) > 0 {
                userVariable = variables?[0] as? UserVariable
            } else {
                userVariable = nil
            }
        }
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    func brickTitle() -> String? {
        return kLocalizedShowVariable + ("\n%@\n" + (kLocalizedAt + (kLocalizedXLabel + ("%@ " + (kLocalizedYLabel + ("%@"))))))
    }
    
    // MARK: - Description
    
    override func description() -> String {
        if let aVariable = userVariable {
            return "ShowTextBrick (Uservariable: \(aVariable))"
        }
        return ""
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(userVariable?.isEqual(to: (brick as? ShowTextBrick)?.userVariable) ?? false) {
            return false
        }
        if !(xFormula?.isEqual(to: (brick as? ShowTextBrick)?.xFormula) ?? false) {
            return false
        }
        if !(yFormula?.isEqual(to: (brick as? ShowTextBrick)?.yFormula) ?? false) {
            return false
        }
        return true
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return (xFormula?.getRequiredResources() ?? 0) | (yFormula?.getRequiredResources() ?? 0)
    }
}
