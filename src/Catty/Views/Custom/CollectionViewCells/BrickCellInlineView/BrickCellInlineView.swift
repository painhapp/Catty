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

import UIKit

class BrickCellInlineView: UIView {
    func dataSubview(forLineNumber line: Int, andParameterNumber parameter: Int) -> BrickCellDataProtocol? {
        for view: UIView in subviews {
            if view is BrickCellDataProtocol {
                let brickCellData = view as! BrickCellDataProtocol
                if brickCellData.lineNumber == line && brickCellData.parameterNumber == parameter {
                    return brickCellData
                }
            }
        }
        return nil
    }

    func dataSubview(withType className: AnyClass) -> BrickCellDataProtocol? {
        for view: UIView in subviews {
            if view is BrickCellDataProtocol && (view .isKind(of: className)) {
                let brickCellData = view as! BrickCellDataProtocol
                return brickCellData
            }
        }
        return nil
    }

    func dataSubviews() -> [Any]? {
        var dataSubviews = [AnyHashable]()
        for view: UIView in subviews {
            if view is BrickCellDataProtocol {
                dataSubviews.append(view)
            }
        }
        return dataSubviews
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }

    // MARK: - BrickCellData

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
