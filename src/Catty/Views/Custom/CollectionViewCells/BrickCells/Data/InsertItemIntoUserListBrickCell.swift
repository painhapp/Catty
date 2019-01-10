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

class InsertItemIntoUserListBrickCell: BrickCell {
    weak var listComboBoxView: iOSCombobox?
    weak var valueTextField: UITextField?
    weak var positionTextField: UITextField?
    private var firstRowTextLabel1: UILabel?
    private var firstRowTextLabel2: UILabel?
    private var thirdRowTextLabel: UILabel?
    
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
        firstRowTextLabel1 = inlineViewSubViews?[0] as? UILabel
        valueTextField = inlineViewSubViews?[1] as? UITextField
        firstRowTextLabel2 = inlineViewSubViews?[2] as? UILabel
        listComboBoxView = inlineViewSubViews?[3] as? iOSCombobox
        thirdRowTextLabel = inlineViewSubViews?[4] as? UILabel
        positionTextField = inlineViewSubViews?[5] as? UITextField
    }
}
