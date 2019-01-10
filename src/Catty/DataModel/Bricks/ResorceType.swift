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

enum ResourceType : Int {
    case defaultResource = 0
    static let noResources = 0
    static let textToSpeech = 1 << 0
    static let bluetoothPhiro = 1 << 1
    static let bluetoothArduino = 1 << 2
    static let faceDetection = 1 << 3
    static let vibration = 1 << 4
    static let location = 1 << 5
    static let accelerometer = 1 << 6
    static let gyro = 1 << 7
    static let magnetometer = 1 << 8
    static let loudness = 1 << 9
    static let led = 1 << 10
    static let compass = 1 << 11
    static let deviceMotion = 1 << 12
    static let touchHandler = 1 << 13
    static let accelerometerAndDeviceMotion = ResourceType.accelerometer | ResourceType.deviceMotion
}
