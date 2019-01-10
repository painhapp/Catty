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

class PhiroHelper: NSObject {
    static func light(toString formatType: Light) -> String {
        var result: String = ""

        switch formatType {
        case Light.lBoth:
            result = kLocalizedPhiroBoth
        case Light.lRight:
            result = kLocalizedPhiroRight
        case Light.lLeft:
            result = kLocalizedPhiroLeft
        default:
            var asdf = 1// TODO: CONVERT NSException.raise(NSExceptionName.genericException, format: "Unexpected FormatType.")
        }

        return result
    }

    static func string(toLight string: String?) -> Light {
        if (string == kLocalizedPhiroBoth) {
            return Light.lBoth
        } else if (string == kLocalizedPhiroRight) {
            return Light.lRight
        } else if (string == kLocalizedPhiroLeft) {
            return Light.lLeft
        }
        return Light.lBoth
    }

    static func tone(toString formatType: Tone) -> String {
        var result: String = ""

        switch formatType {
        case Tone.doX:
            result = kLocalizedPhiroDO
        case Tone.re:
            result = kLocalizedPhiroRE
        case Tone.mi:
            result = kLocalizedPhiroMI
        case Tone.fa:
            result = kLocalizedPhiroFA
        case Tone.so:
            result = kLocalizedPhiroSO
        case Tone.la:
            result = kLocalizedPhiroLA
        case Tone.ti:
            result = kLocalizedPhiroTI
        default:
            var asdf = 1// TODO: CONVERT NSException.raise(NSExceptionName.genericException, format: "Unexpected FormatType.")
        }

        return result
    }

    static func string(toTone string: String?) -> Tone {
        if (string == kLocalizedPhiroDO) {
            return Tone.doX
        } else if (string == kLocalizedPhiroRE) {
            return Tone.re
        } else if (string == kLocalizedPhiroMI) {
            return Tone.mi
        } else if (string == kLocalizedPhiroFA) {
            return Tone.fa
        } else if (string == kLocalizedPhiroSO) {
            return Tone.so
        } else if (string == kLocalizedPhiroLA) {
            return Tone.la
        } else if (string == kLocalizedPhiroTI) {
            return Tone.ti
        }
        return Tone.doX
    }

    static func motor(toString formatType: Motor) -> String {
        var result: String = ""

        switch formatType {
        case Motor.both:
            result = kLocalizedPhiroBoth
        case Motor.right:
            result = kLocalizedPhiroRight
        case Motor.left:
            result = kLocalizedPhiroLeft
        default:
            var asdf = 1// TODO: CONVERT NSException.raise(NSExceptionName.genericException, format: "Unexpected FormatType.")
        }

        return result
    }

    static func string(toMotor string: String?) -> Motor {
        if (string == kLocalizedPhiroBoth) {
            return Motor.both
        } else if (string == kLocalizedPhiroRight) {
            return Motor.right
        } else if (string == kLocalizedPhiroLeft) {
            return Motor.left
        }
        return Motor.both
    }
}
