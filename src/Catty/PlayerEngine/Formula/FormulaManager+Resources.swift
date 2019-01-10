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

import CoreLocation
import CoreMotion

extension FormulaManager {

    func unavailableResources(for requiredResources: NSInteger) -> NSInteger {
        var unavailableResource: Int = ResourceType.noResources

        if requiredResources & ResourceType.accelerometer > 0 &&
            !motionManager.isAccelerometerAvailable {
            unavailableResource |= ResourceType.accelerometer
        }
        if requiredResources & ResourceType.deviceMotion > 0 &&
            !motionManager.isDeviceMotionAvailable {
            unavailableResource |= ResourceType.deviceMotion
        }
        if requiredResources & ResourceType.location > 0 &&
            !type(of: locationManager).locationServicesEnabled() {
            unavailableResource |= ResourceType.location
        }
        if requiredResources & ResourceType.vibration > 0 &&
            !Util.isPhone() {
            unavailableResource |= ResourceType.vibration
        }
        if requiredResources & ResourceType.compass > 0 &&
            !type(of: locationManager).headingAvailable() {
            unavailableResource |= ResourceType.compass
        }
        if requiredResources & ResourceType.gyro > 0 &&
            !motionManager.isGyroAvailable {
            unavailableResource |= ResourceType.gyro
        }
        if requiredResources & ResourceType.magnetometer > 0 &&
            !motionManager.isMagnetometerAvailable {
            unavailableResource |= ResourceType.magnetometer
        }
        if requiredResources & ResourceType.faceDetection > 0 &&
            !faceDetectionManager.available() {
            unavailableResource |= ResourceType.faceDetection
        }
        if requiredResources & ResourceType.loudness > 0 &&
            !audioManager.loudnessAvailable() {
            unavailableResource |= ResourceType.loudness
        }

        return unavailableResource
    }

    @objc(setupForProgram: andScene:)
    func setup(for program: Program, and scene: CBScene) {
        let requiredResources = program.getRequiredResources()
        setup(for: requiredResources, and: scene, startTrackingTouches: true)
    }

    @objc(setupForFormula:)
    func setup(for formula: Formula) {
        let requiredResources = formula.getRequiredResources()
        setup(for: requiredResources, and: nil, startTrackingTouches: false)
    }

    private func setup(for requiredResources: Int, and scene: CBScene?, startTrackingTouches: Bool) {
        let unavailableResource = unavailableResources(for: requiredResources)

        if (requiredResources & ResourceType.accelerometer > 0) &&
            (unavailableResource & ResourceType.accelerometer) == 0 {
            motionManager.startAccelerometerUpdates()
        }
        if (requiredResources & ResourceType.deviceMotion > 0) &&
            (unavailableResource & ResourceType.deviceMotion) == 0 {
            motionManager.startDeviceMotionUpdates()
        }
        if (requiredResources & ResourceType.magnetometer > 0) &&
            (unavailableResource & ResourceType.magnetometer) == 0 {
            motionManager.startMagnetometerUpdates()
        }
        if (requiredResources & ResourceType.gyro > 0) &&
            (unavailableResource & ResourceType.gyro) == 0 {
            motionManager.startGyroUpdates()
        }
        if (requiredResources & ResourceType.compass > 0) &&
            (unavailableResource & ResourceType.compass) == 0 {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingHeading()
        }
        if (requiredResources & ResourceType.location > 0) &&
            (unavailableResource & ResourceType.location) == 0 {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        if ((requiredResources & ResourceType.faceDetection) > 0) &&
            (unavailableResource & ResourceType.faceDetection) == 0 {
            faceDetectionManager.start()
        }
        if ((requiredResources & ResourceType.loudness) > 0) &&
            (unavailableResource & ResourceType.loudness) == 0 {
            audioManager.startLoudnessRecorder()
        }

        if startTrackingTouches {
            guard let sc = scene else { return }
            touchManager.startTrackingTouches(for: sc)
        }
    }

    @objc func stop() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        faceDetectionManager.stop()
        audioManager.stopLoudnessRecorder()
        touchManager.stopTrackingTouches()

        invalidateCache()
    }

    func pause() {
        audioManager.pauseLoudnessRecorder()
    }

    func resume() {
        audioManager.resumeLoudnessRecorder()
    }
}
