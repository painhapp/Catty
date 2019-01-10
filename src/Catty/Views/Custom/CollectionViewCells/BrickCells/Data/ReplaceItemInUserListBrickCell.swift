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

class ReplaceItemInUserListBrickCell: BrickCell {
    weak var listComboBoxView: iOSCombobox?
    weak var valueTextField: UITextField?
    weak var positionTextField: UITextField?
    private var firstRowTextLabel: UILabel?
    private var thirdRowTextLabel1: UILabel?
    private var thirdRowTextLabel2: UILabel?
    
    override func draw(_ rect: CGRect) {
        BrickShapeFactory.drawSquareBrickShape(withFill: UIColor.variableBrickRed(),
                                               stroke: UIColor.variableBrickStroke(),
                                               height: CGFloat(largeBrick),
                                               width: Util.screenWidth())
    }
    
    override func cellHeight() -> CGFloat {
        return BrickHeightType.height3.rawValue
    }
    
    override func hookUpSubViews(_ inlineViewSubViews: [Any]?) {
        firstRowTextLabel = inlineViewSubViews?[0] as? UILabel
        listComboBoxView = inlineViewSubViews?[1] as? iOSCombobox
        thirdRowTextLabel1 = inlineViewSubViews?[2] as? UILabel
        positionTextField = inlineViewSubViews?[3] as? UITextField
        thirdRowTextLabel2 = inlineViewSubViews?[4] as? UILabel
        valueTextField = inlineViewSubViews?[5] as? UITextField
    }
}
