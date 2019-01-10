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

import Foundation

class Formula: NSObject, CBMutableCopying {
    var formulaTree: FormulaElement?
    
    private var _displayString: String?
    var displayString: String? {
        get {
            return _displayString
        }
        set(text) {
            if text == nil {
                _displayString = nil
            } else {
                _displayString = "\(text ?? "")"
            }
        }
    }
    
    convenience override init() {
        self.init(integer: 0)
    }
    
    init(integer value: Int) {
        super.init()

        if value < 0 {
            let absValue = abs(value)
            formulaTree = FormulaElement(elementType: ElementType.formulaOperator, value: Operators.getName(Operator.minus), leftChild: nil, rightChild: nil, parent: nil)
            let rightChild = FormulaElement(elementType: .number, value: "\(absValue)", leftChild: nil, rightChild: nil, parent: formulaTree)
            formulaTree?.rightChild = rightChild
        } else {
            formulaTree = FormulaElement(elementType: .number, value: "\(value)", leftChild: nil, rightChild: nil, parent: nil)
        }
        
    }
    
    init(double value: Double) {
        super.init()

        if value < 0 {
            let absValue = Double(abs(Float(value)))
            formulaTree = FormulaElement(elementType: ElementType.formulaOperator, value: Operators.getName(Operator.minus), leftChild: nil, rightChild: nil, parent: nil)
            let rightChild = FormulaElement(elementType: .number, value: "\(absValue)", leftChild: nil, rightChild: nil, parent: formulaTree)
            formulaTree?.rightChild = rightChild
        } else {
            formulaTree = FormulaElement(elementType: .number, value: "\(value)", leftChild: nil, rightChild: nil, parent: nil)
        }
        
    }
    
    convenience init(float value: Float) {
        self.init(double: Double(value))
    }
    
    init(string value: String) {
        super.init()
        
        
        let formulaElement = FormulaElement()
        formulaElement.type = .string
        formulaElement.value = value
        formulaTree = formulaElement
        
    }
    
    init(formulaElement formulaTree: FormulaElement?) {
        super.init()
        
        self.formulaTree = formulaTree
    }
    
    func isSingularNumber() -> Bool {
        return (formulaTree?.isSingleNumberFormula() ?? false || formulaTree?.type == .string) && Double(formulaTree?.value ?? "") ?? 0.0 == 1.0
    }
    
    func isEqual(to formula: Formula?) -> Bool {
        if formulaTree?.isEqual(to: formula?.formulaTree) ?? false {
            return true
        }
        return false
    }
    
    func setRoot(_ formulaTree: FormulaElement?) {
        displayString = nil
        self.formulaTree = formulaTree
    }
    
    func getInternFormulaState() -> InternFormulaState? {
        return getInternFormula()?.getState()
    }
    
    func getDisplayString() -> String? {
        if displayString != nil {
            return displayString
        } else {
            let internFormula = getInternFormula()
            internFormula?.generateExternFormulaStringAndInternExternMapping()
            return internFormula?.getExternFormulaString()
        }
    }
    
    func getInternFormula() -> InternFormula? {
        let internFormula = InternFormula(internTokenList: (formulaTree?.getInternTokenList() as! NSMutableArray))
        return internFormula
    }
    
    func getRequiredResources() -> Int {
        return formulaTree?.getRequiredResources() ?? 0
    }
    
    // MARK: - Copy
    
    func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        let formula = Formula()
        if formulaTree != nil {
            formula.formulaTree = formulaTree?.mutableCopy(with: context) as? FormulaElement
        }
        return formula
    }
    
    // MARK: - Resources
}
