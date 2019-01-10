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

class TableUtil: NSObject {

    static let featuredProgramsBannerHeight: CGFloat = 400.0
    static let featuredProgramsBannerWidth: CGFloat = 1024.0

    static func height(forContinueCell navBarHeight: CGFloat) -> CGFloat {
        var screenHeight = Util.screenHeight()
        screenHeight -= navBarHeight
        return screenHeight * 0.25
    }

    static func heightForImageCell() -> CGFloat {
        let screenHeight = Util.screenHeight()
        return screenHeight / 7.0
    }

    static func height(forCatrobatTableViewImageCell navBarHeight: CGFloat) -> CGFloat {
        var screenHeight = Util.screenHeight()
        screenHeight -= navBarHeight
        return screenHeight * 0.14
    }

    static func heightForFeaturedCell() -> CGFloat {
        return featuredProgramsBannerHeight / (featuredProgramsBannerWidth / Util.screenWidth())
    }

    static func editButtonItem(withTarget target: Any?, action: Selector) -> UIBarButtonItem? {
        let editButton = UIBarButtonItem(title: kLocalizedEdit, style: .plain, target: target, action: action)
        return editButton
    }
}
