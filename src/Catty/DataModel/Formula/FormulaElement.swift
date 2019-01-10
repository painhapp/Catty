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

enum ElementType : Int {
    case formulaOperator = 10000
    case function
    case number
    case sensor
    case userVariable
    case userList
    case bracket
    case string
}

enum IdempotenceState : Int {
    case notChecked = 0 //not_CHECKED
    case idempotent
    case notIdempotent //not_IDEMPOTENT
}

let ARC4RANDOM_MAX = 0x100000000
let kEmptyStringFallback = ""
let kZeroFallback = 0

class FormulaElement: NSObject, CBMutableCopying {
    var type: ElementType
    var value = ""
    var leftChild: FormulaElement?
    var rightChild: FormulaElement?
    var parent: FormulaElement?
    var idempotenceState: IdempotenceState?

    init(type: String?, value: String?, leftChild: FormulaElement?, rightChild: FormulaElement?, parent: FormulaElement?) {
        super.init()
        
        initialize(elementType(for: type), value: value, leftChild: leftChild, rightChild: rightChild, parent: parent)
        idempotenceState = IdempotenceState.notChecked
        
    }
    
    init(elementType type: ElementType, value: String?, leftChild: FormulaElement?, rightChild: FormulaElement?, parent: FormulaElement?) {
        super.init()
        
        initialize(type, value: value, leftChild: leftChild, rightChild: rightChild, parent: parent)
        idempotenceState = IdempotenceState.notChecked
    }
    
    convenience init(elementType type: ElementType, value: String?) {
        self.init(elementType: type, value: value, leftChild: nil, rightChild: nil, parent: nil)
    }
    
    convenience init(integer value: Int) {
        self.init(type: "NUMBER", value: "\(value)", leftChild: nil, rightChild: nil, parent: nil)
    }
    
    convenience init(double value: Double) {
        self.init(type: "NUMBER", value: "\(value)", leftChild: nil, rightChild: nil, parent: nil)
    }
    
    convenience init(string value: String) {
        self.init(type: "STRING", value: value, leftChild: nil, rightChild: nil, parent: nil)
    }

    // TODO: CONVERT fix this
    required convenience override init() {
        self.init(type: "STRING", value: "", leftChild: nil, rightChild: nil, parent: nil)
    }
    
    func isEqual(to formulaElement: FormulaElement?) -> Bool {
        if type != formulaElement?.type {
            return false
        }
        if !Util.isEqual(value, to: formulaElement?.value) {
            return false
        }
        if (leftChild != nil && formulaElement?.leftChild == nil) || (leftChild == nil && formulaElement?.leftChild != nil) {
            return false
        }
        if leftChild != nil && !(leftChild?.isEqual(to: formulaElement?.leftChild) ?? false) {
            return false
        }
        if (rightChild != nil && formulaElement?.rightChild == nil) || (rightChild == nil && formulaElement?.rightChild != nil) {
            return false
        }
        if rightChild != nil && !(rightChild?.isEqual(to: formulaElement?.rightChild) ?? false) {
            return false
        }
        if (parent != nil && formulaElement?.parent == nil) || (parent == nil && formulaElement?.parent != nil) {
            return false
        }
        // FIXME: this leads to an endless recursion bug!!!
        //    if(self.parent != nil && ![self.parent isEqualToFormulaElement:formulaElement.parent])
        //        return NO;
        if (parent != nil) || (formulaElement?.parent != nil) {
            return false
        }
        
        return true
    }
    
    func getRoot() -> FormulaElement? {
        var root: FormulaElement = self
        while root.parent != nil {
            if let aParent = root.parent {
                root = aParent
            }
        }
        return root
    }
    
    func replace(_ current: FormulaElement?) {
        parent = current?.parent
        leftChild = current?.leftChild
        rightChild = current?.rightChild
        value = current?.value ?? ""
        type = (current?.type)!
        
        if leftChild != nil {
            leftChild?.parent = self
        }
        if rightChild != nil {
            rightChild?.parent = self
        }
    }

    func elementType(for type: String?) -> ElementType {
        let dict = ["OPERATOR": ElementType.formulaOperator,
                    "FUNCTION": ElementType.function,
                    "NUMBER": ElementType.number,
                    "SENSOR": ElementType.sensor,
                    "USER_VARIABLE": ElementType.userVariable,
                    "USER_LIST": ElementType.userList,
                    "BRACKET": ElementType.bracket,
                    "STRING": ElementType.string]
        guard let elementType = dict[type!] else {
            // TODO: CONVERT NSError("Unknown Type: %@", type)
            return ElementType(rawValue: -1)!
        }
        return elementType


    }

    func string(for type: ElementType) -> String? {
        let dict = [ElementType.formulaOperator: "OPERATOR",
                    ElementType.function: "FUNCTION",
                    ElementType.number: "NUMBER",
                    ElementType.sensor: "SENSOR",
                    ElementType.userVariable: "USER_VARIABLE",
                    ElementType.userList: "USER_LIST",
                    ElementType.bracket: "BRACKET",
                    ElementType.string: "STRING"]
        let elementType = dict[type]
        if elementType != "" {
            return elementType
        }
        //TODO: Convert NSError("Unknown Type: %@", type)
        return nil
    }
    
    func replace(_ type: ElementType, value: String?) {
        self.type = type
        self.value = value ?? ""
    }
    
    func replace(withSubElement operatorValue: String?, rightChild: FormulaElement?) {
        let cloneThis = FormulaElement(elementType: ElementType.formulaOperator, value: operatorValue, leftChild: self, rightChild: rightChild, parent: parent)
        
        cloneThis.parent?.rightChild = cloneThis
    }
    
    func getInternTokenList() -> [AnyHashable]? {
        var internTokenList: [AnyHashable] = []
        
        switch type {
        case ElementType.bracket:
            internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
            if rightChild != nil {
                if let aList = rightChild?.getInternTokenList() {
                    internTokenList.append(contentsOf: aList)
                }
            }
            internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        case ElementType.formulaOperator:
            if leftChild != nil {
                if let aList = leftChild?.getInternTokenList() {
                    internTokenList.append(contentsOf: aList)
                }
            }
            internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: value))
            if rightChild != nil {
                if let aList = rightChild?.getInternTokenList() {
                    internTokenList.append(contentsOf: aList)
                }
            }
        case ElementType.function:
            internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: value))
            var functionHasParameters = false
            if leftChild != nil {
                internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
                functionHasParameters = true
                if let aList = leftChild?.getInternTokenList() {
                    internTokenList.append(contentsOf: aList)
                }
            }
            if rightChild != nil {
                internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
                if let aList = rightChild?.getInternTokenList() {
                    internTokenList.append(contentsOf: aList)
                }
            }
            if functionHasParameters {
                internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
            }
        case ElementType.userVariable:
            internTokenList.append(InternToken(type: TOKEN_TYPE_USER_VARIABLE, andValue: value))
        case ElementType.userList:
            internTokenList.append(InternToken(type: TOKEN_TYPE_USER_LIST, andValue: value))
        case ElementType.number:
            internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: value))
        case ElementType.sensor:
            internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: value))
            var functionHasParameters = false
            if leftChild != nil {
                internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
                functionHasParameters = true
                if let aList = leftChild?.getInternTokenList() {
                    internTokenList.append(contentsOf: aList)
                }
            }
            if rightChild != nil {
                internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
                if let aList = rightChild?.getInternTokenList() {
                    internTokenList.append(contentsOf: aList)
                }
            }
            if functionHasParameters {
                internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
            } else {
                internTokenList.removeAll()
                internTokenList.append(InternToken(type: TOKEN_TYPE_SENSOR, andValue: value))
            }
        case ElementType.string:
            internTokenList.append(InternToken(type: TOKEN_TYPE_STRING, andValue: value))
        default:
            break
        }
        return internTokenList
    }
    
    func isSingleNumberFormula() -> Bool {
        if type == .formulaOperator {
            if  Operators.getOperatorByValue(value) == .minus && leftChild == nil {
                return rightChild?.isSingleNumberFormula() ?? false
            }
            return false
        } else if type == .number {
            return true
        }
        return false
    }
    
    func getRequiredResources() -> Int {
        var resources: Int = ResourceType.noResources
        if leftChild != nil {
            resources |= leftChild?.getRequiredResources() ?? 0
        }
        if rightChild != nil {
            resources |= rightChild?.getRequiredResources() ?? 0
        }
        if type == .sensor {
            resources |= SensorManager.self.requiredResource(tag: value)
        }
        if type == .function {
            resources |= FunctionManager.self.requiredResource(tag: value)
        }
        return resources
    }
    
    func initialize(_ type: ElementType, value: String?, leftChild: FormulaElement?, rightChild: FormulaElement?, parent: FormulaElement?) {
        self.type = type
        self.value = value ?? ""
        self.leftChild = leftChild
        self.rightChild = rightChild
        self.parent = parent
        
        if self.leftChild != nil {
            self.leftChild?.parent = self
        }
        if self.rightChild != nil {
            self.rightChild?.parent = self
        }
    }
    
    func isStringDecimalNumber(_ stringValue: String?) -> Bool {
        var result = false
        
        let decimalRegex = "^(?:|-)(?:|0|[1-9]\\d*)(?:\\.\\d*)?$"
        let regexPredicate = NSPredicate(format: "SELF MATCHES %@", decimalRegex)
        
        if regexPredicate.evaluate(with: stringValue) {
            //Matches
            result = true
        }
        
        return result
    }
    
    func description() -> String {
        return String(format: "Formula Element: Type: %lu, Value: %@", type.rawValue, value)
    }
    
    func doubleIsInteger(_ number: Double) -> Bool {
        if ceil(number) == number || floor(number) == number {
            return true
        }
        return false
    }
    
    // MARK: - Copy
    
    func mutableCopy(with context: CBMutableCopyContext?) -> Any? {
        let leftChildClone = leftChild == nil ? nil : leftChild?.mutableCopy(with: context)
        let rightChildClone = rightChild == nil ? nil : rightChild?.mutableCopy(with: context)
        return FormulaElement(elementType: type, value: value, leftChild: leftChildClone, rightChild: rightChildClone, parent: nil)
    }
    
    // MARK: - Resources
}
