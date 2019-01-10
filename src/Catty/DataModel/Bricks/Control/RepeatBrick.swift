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

class RepeatBrick: LoopBeginBrick, BrickFormulaProtocol {
    var timesToRepeat: Formula?
    var loopCount: Int = 0
    
    override func isLoopBrick() -> Bool {
        return true
    }
    
    override func isAnimateable() -> Bool {
        return true
    }
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        return timesToRepeat
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        timesToRepeat = formula
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    func getFormulas() -> [Formula]? {
        return [timesToRepeat!]
    }
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        timesToRepeat = Formula(integer: 10)
    }
    
    func brickTitle() -> String? {
        let repeatForStr = timesToRepeat?.isSingularNumber() ?? false ? kLocalizedTime : kLocalizedTimes
        return kLocalizedRepeat + ("%@ " + (repeatForStr))
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "RepeatLoop"
    }
    
    // MARK: - Copy
    
    override func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        let brick = mutableCopy(with: context, andErrorReporting: false) as? RepeatBrick
        brick?.loopCount = loopCount
        return brick
    }
    
    // MARK: - Resources
    
    override func getRequiredResources() -> Int {
        return timesToRepeat?.getRequiredResources() ?? 0
    }
}
