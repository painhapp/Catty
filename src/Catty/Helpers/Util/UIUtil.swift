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

typealias row_action_block_t = (UITableViewRowAction, IndexPath) -> Void

class UIUtil: NSObject {
    static func tableViewMoreRowAction(withHandler handler: @escaping row_action_block_t) -> UITableViewRowAction? {
        var moreRowAction: UITableViewRowAction? = nil
        moreRowAction = UITableViewRowAction(style: .default, title: kLocalizedMore, handler: handler)
        moreRowAction?.backgroundColor = UIColor.clear
        return moreRowAction
    }

    static func tableViewDeleteRowAction(withHandler handler: @escaping row_action_block_t) -> UITableViewRowAction? {
        var deleteRowAction: UITableViewRowAction? = nil
        deleteRowAction = UITableViewRowAction(style: .default, title: kLocalizedDelete, handler: handler)
        deleteRowAction?.backgroundColor = UIColor.destructiveTint()
        return deleteRowAction
    }

    static func newDefaultBrickLabel(withFrame frame: CGRect) -> UILabel? {
        return self.newDefaultBrickLabel(withFrame: frame, andText: nil, andRemainingSpace: Int(kBrickInputFieldMaxWidth))
    }

    static func newDefaultBrickLabel(withFrame frame: CGRect, andText text: String?, andRemainingSpace remainingSpace: Int) -> UILabel? {
        let label = UILabel(frame: frame)
        label.textColor = UIColor.white
        if let aSize = UIFont(name: "Helvetica-Bold", size: kBrickLabelFontSize) {
            label.font = aSize
        }
        if text != nil {
            label.text = text
            // adapt size to fit text
            label.sizeToFit()
            if label.frame.size.width >= CGFloat(remainingSpace) {
                label.frame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y, width: CGFloat(remainingSpace), height: label.frame.size.height)
                label.numberOfLines = 1
                label.adjustsFontSizeToFitWidth = true
                label.lineBreakMode = .byTruncatingTail
                label.minimumScaleFactor = 14.0 / label.font.pointSize
            } else {
                label.numberOfLines = 1
                label.lineBreakMode = .byTruncatingTail
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 14.0 / label.font.pointSize
            }
            var labelFrame: CGRect = label.frame
            labelFrame.size.height = frame.size.height
            label.frame = labelFrame
        }
        return label
    }

    static func newDefaultBrickComboBox(withFrame frame: CGRect, andItems items: [Any]?) -> iOSCombobox? {
        let comboBox = iOSCombobox(frame: frame)
        comboBox.values = items
        return comboBox
    }
}
