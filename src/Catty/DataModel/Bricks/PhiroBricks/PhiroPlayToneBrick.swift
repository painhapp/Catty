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

class PhiroPlayToneBrick: PhiroBrick, BrickFormulaProtocol, BrickPhiroToneProtocol {
    var durationFormula: Formula?
    var tone = ""
    
    func phiroTone() -> Tone {
        return PhiroHelper.string(toTone: tone)
    }
    
    func brickTitle() -> String? {
        return kLocalizedPhiroPlayTone + ("%@\n") + (kLocalizedPhiroPlayDuration) + ("%@ ") + (kLocalizedPhiroSecondsToPlay)
    }
    
    // MARK: - Description
    
    override func description() -> String {
        return "PhiroPlayToneBrick"
    }
    
    override func isEqual(to brick: Brick?) -> Bool {
        if !(durationFormula?.isEqual(to: (brick as? PhiroPlayToneBrick)?.durationFormula) ?? false) {
            return false
        }
        return true
    }
    
    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula? {
        return durationFormula
    }
    
    func setFormula(_ formula: Formula?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        durationFormula = formula
    }
    
    func getFormulas() -> [Formula]? {
        return [durationFormula!]
    }
    
    func allowsStringFormula() -> Bool {
        return false
    }
    
    func tone(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> String? {
        return tone
    }
    
    func setTone(_ tone: String?, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.tone = tone ?? ""
    }
    
    // MARK: - Default values
    
    override func setDefaultValuesFor(_ spriteObject: SpriteObject?) {
        tone = PhiroHelper.tone(toString: Tone.doX)
        durationFormula = Formula()
    }
}
