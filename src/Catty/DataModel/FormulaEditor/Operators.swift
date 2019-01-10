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

enum Operator : Int {
    case logicalAnd = 400
    case logicalOr
    case equal
    case notEqual
    case smallerOrEqual
    case greaterOrEqual
    case smallerThan
    case greaterThan
    case plus
    case minus
    case mult
    case divide
    case logicalNot
    case decimalMark
    case noOperator = -1
}

class Operators: NSObject {
    static func getName(_ operatorValue: Operator) -> String? {
        let formatter = NumberFormatter()
        var name: String
        switch operatorValue {
        case .logicalAnd:
            name = "LOGICAL_AND"
        case .logicalOr:
            name = "LOGICAL_OR"
        case .logicalNot:
            name = "LOGICAL_NOT"
        case .equal:
            name = "EQUAL"
        case .notEqual:
            name = "NOT_EQUAL"
        case .smallerOrEqual:
            name = "SMALLER_OR_EQUAL"
        case .greaterOrEqual:
            name = "GREATER_OR_EQUAL"
        case .smallerThan:
            name = "SMALLER_THAN"
        case .greaterThan:
            name = "GREATER_THAN"
        case .plus:
            name = "PLUS"
        case .minus:
            name = "MINUS"
        case .mult:
            name = "MULT"
        case .divide:
            name = "DIVIDE"
        case .decimalMark:
            name = formatter.decimalSeparator
        default:
            return nil
        }
        return name
    }
    
    static func getExternName(_ value: String?) -> String? {
        var name: String
        let operatorValue: Operator = self.getOperatorByValue(value)
        let formatter = NumberFormatter()
        
        switch operatorValue {
        case .logicalAnd:
            name = kUIFEOperatorAnd
        case .logicalOr:
            name = kUIFEOperatorOr
        case .logicalNot:
            name = kUIFEOperatorNot
        case .equal:
            name = "="
        case .notEqual:
            name = "≠"
        case .smallerOrEqual:
            name = "≤"
        case .greaterOrEqual:
            name = "≥"
        case .smallerThan:
            name = "<"
        case .greaterThan:
            name = ">"
        case .plus:
            name = "+"
        case .minus:
            name = "-"
        case .mult:
            name = "×"
        case .divide:
            name = "÷"
        case .decimalMark:
            name = formatter.decimalSeparator
        default:
            print("Invalid operator")
        }
        return name
    }
    
    static func getOperatorByValue(_ name: String?) -> Operator {
        let formatter = NumberFormatter()
        if (name == "LOGICAL_AND") {
            return .logicalAnd
        }
        if (name == "LOGICAL_OR") {
            return .logicalOr
        }
        if (name == "EQUAL") {
            return .equal
        }
        if (name == "NOT_EQUAL") {
            return .notEqual
        }
        if (name == "SMALLER_OR_EQUAL") {
            return .smallerOrEqual
        }
        if (name == "GREATER_OR_EQUAL") {
            return .greaterOrEqual
        }
        if (name == "SMALLER_THAN") {
            return .smallerThan
        }
        if (name == "GREATER_THAN") {
            return .greaterThan
        }
        if (name == "PLUS") {
            return .plus
        }
        if (name == "MINUS") {
            return .minus
        }
        if (name == "MULT") {
            return .mult
        }
        if (name == "DIVIDE") {
            return .divide
        }
        if (name == "LOGICAL_NOT") {
            return .logicalNot
        }
        if (name == formatter.decimalSeparator) {
            return .decimalMark
        }
        return .noOperator
    }
    
    static func getPriority(_ operatorValue: Operator) -> Int {
        var priority: Int = 0
        switch operatorValue {
        case .logicalAnd:
            priority = 2
        case .logicalOr:
            priority = 1
        case .logicalNot:
            priority = 4
        case .equal:
            priority = 3
        case .notEqual:
            priority = 4
        case .smallerOrEqual:
            priority = 4
        case .greaterOrEqual:
            priority = 4
        case .smallerThan:
            priority = 4
        case .greaterThan:
            priority = 4
        case .plus:
            priority = 5
        case .minus:
            priority = 5
        case .mult:
            priority = 6
        case .divide:
            priority = 6
        default:
            print("Invalid operator")
        }
        return priority
    }
    
    static func isLogicalOperator(_ operatorValue: Operator) -> Bool {
        var isLogical = false
        switch operatorValue {
        case .logicalAnd:
            isLogical = true
        case .logicalOr:
            isLogical = true
        case .logicalNot:
            isLogical = true
        case .equal:
            isLogical = true
        case .notEqual:
            isLogical = true
        case .smallerOrEqual:
            isLogical = true
        case .greaterOrEqual:
            isLogical = true
        case .smallerThan:
            isLogical = true
        case .greaterThan:
            isLogical = true
        case .plus:
            isLogical = false
        case .minus:
            isLogical = false
        case .mult:
            isLogical = false
        case .divide:
            isLogical = false
        default:
            print("Invalid operator")
        }
        return isLogical
    }
    
    static func compare(_ firstOperator: Operator, with secondOperator: Operator) -> Int {
        var returnValue: Int = 0
        if self.getPriority(firstOperator) > self.getPriority(secondOperator) {
            returnValue = 1
        } else if self.getPriority(firstOperator) == self.getPriority(secondOperator) {
            returnValue = 0
        } else if self.getPriority(firstOperator) < self.getPriority(secondOperator) {
            returnValue = -1
        }
        
        return returnValue
    }
    
    static func isOperator(_ value: String?) -> Bool {
        if self.getOperatorByValue(value).rawValue == -1 {
            return false
        }
        
        return true
    }
}
