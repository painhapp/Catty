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

class BrickCellListData: iOSCombobox, BrickCellDataProtocol, iOSComboboxDelegate {
    weak var brickCell: BrickCell?
    var lineNumber: Int = 0
    var parameterNumber: Int = 0
    
    required init(frame: CGRect, andBrickCell brickCell: BrickCell?, andLineNumber line: Int, andParameterNumber parameter: Int) {
        //if super.init(frame: frame)
        
        self.brickCell = brickCell
        lineNumber = line
        parameterNumber = parameter
        
        var options: [String] = []
        options.append(kLocalizedNewElement)
        var currentOptionIndex: Int = 0
        if !(brickCell?.isInserting ?? false) {
            let optionIndex: Int = 1
            if brickCell?.scriptOrBrick is BrickListProtocol != nil {
                let listBrick = brickCell?.scriptOrBrick as? (Brick & BrickListProtocol)
                let currentList: UserVariable? = listBrick?.list(forLineNumber: line, andParameterNumber: parameter)
                for list: UserVariable? in (listBrick?.script!.object!.program!.variables.allLists(for: listBrick?.script!.object))! {
                    if let aName = list?.name {
                        options.append(aName)
                    }
                    if (list?.name == currentList?.name) {
                        currentOptionIndex = optionIndex
                    }
                    optionIndex += 1
                }
                if let aName = currentList?.name {
                    if currentList != nil && !options.contains(aName) {
                        options.append(aName)
                        currentOptionIndex = optionIndex
                    }
                }
            }
        }
        values = options
        currentValue = options[currentOptionIndex]
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func comboboxDonePressed(_ combobox: iOSCombobox?, withValue value: String?) {
        brickCell?.dataDelegate?.updateBrickCellData(self, withValue: value)
    }
    
    func comboboxOpened(_ combobox: iOSCombobox?) {
        brickCell?.dataDelegate?.disableUserInteractionAndHighlight(brickCell, withMarginBottom: CGFloat(kiOSComboboxTotalHeight))
        if combobox?.values.count == 1 {
            comboboxDonePressed(combobox, withValue: combobox?.values.first as! String)
        }
    }
    
    // MARK: - User interaction
    
    func isUserInteractionEnabled() -> Bool {
        return brickCell?.scriptOrBrick?.animateInsertBrick == false
    }
}
