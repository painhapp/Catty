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

class GlideToBrick: Brick, BrickFormulaProtocol {
    var durationInSeconds: Formula?
    var xDestination: Formula?
    var yDestination: Formula?
    var isInitialized = false
    var currentPoint = CGPoint.zero
    var startingPoint = CGPoint.zero
    var deltaX: Float = 0.0
    var deltaY: Float = 0.0
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        if lineNumber == 0 && paramNumber == 0 {
            return durationInSeconds
        } else if lineNumber == 1 && paramNumber == 0 {
            return xDestination
        } else if lineNumber == 1 && paramNumber == 1 {
            return yDestination
        }
        
        return nil
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if lineNumber == 0 && paramNumber == 0 {
            durationInSeconds = formula
        } else if lineNumber == 1 && paramNumber == 0 {
            xDestination = formula
        } else if lineNumber == 1 && paramNumber == 1 {
            yDestination = formula
        }
    }
    
    func getFormulas() -> [Formula]? {
        return [durationInSeconds!, xDestination!, yDestination!]
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        durationInSeconds = Formula(integer: 1)
        xDestination = Formula(integer: 100)
        yDestination = Formula(integer: 200)
    }
    
    override init() {
        //if super.init()
        
        isInitialized = false
        
    }
    
    func brickTitle() -> String? {
        let localizedSecond = durationInSeconds?.isSingularNumber() ?? false ? kLocalizedSecond : kLocalizedSeconds
        return kLocalizedGlide + ("%@ " + (localizedSecond + ("\n" + (kLocalizedToX + ("%@ " + (kLocalizedYLabel + ("%@")))))))
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "GlideToBrick"
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(durationInSeconds?.isEqual(to: (brick as? GlideToBrick)?.durationInSeconds) ?? false) {
            return false
        }
        if !(xDestination?.isEqual(to: (brick as? GlideToBrick)?.xDestination) ?? false) {
            return false
        }
        if !(yDestination?.isEqual(to: (brick as? GlideToBrick)?.yDestination) ?? false) {
            return false
        }
        return true
    }
    
    // MARK: - Copy
    
    override func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        return mutableCopy(with: context, andErrorReporting: false)
        
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return (durationInSeconds?.getRequiredResources() ?? 0) | (xDestination?.getRequiredResources() ?? 0) | (yDestination?.getRequiredResources() ?? 0)
    }
}
