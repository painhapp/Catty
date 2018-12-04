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

class FaceDetectionManager: NSObject, FaceDetectionManagerProtocol {

    var isFaceDetected: Bool = false
    var facePositionRatioFromLeft: Double?
    var facePositionRatioFromBottom: Double?
    var faceSizeRatio: Double?
    var faceDetectionFrameSize: CGSize?

    private var faceDetector: CIDetector?

    func start() {
        self.reset()

        CameraManager.shared.start()

        let detectorOptions = [ CIDetectorAccuracy: CIDetectorAccuracyLow ]
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(captureSubscriber),
            name: NSNotification.Name(rawValue: "CaptureOutputCatty"),
            object: nil)
    }

    func stop() {
        self.reset()
        CameraManager.shared.stop()
        self.faceDetector = nil
    }

    func reset() {
        self.isFaceDetected = false
        self.facePositionRatioFromLeft = nil
        self.facePositionRatioFromBottom = nil
        self.faceSizeRatio = nil
        self.faceDetectionFrameSize = nil
    }

    func available() -> Bool {
        return CameraManager.shared.available()
    }

    @objc
    func captureSubscriber(notification: NSNotification) {
        if notification.object is CIImage {
            let ciImage = notification.object as? CIImage
            guard let features = self.faceDetector?.features(in: ciImage!) else { return }

            self.captureFace(for: features, in: ciImage!.extent)
        }
    }

    func captureFace(for features: [CIFeature], in imageDimensions: CGRect) {
        var isFaceDetected = false

        for feature in features where (feature.type == CIFeatureTypeFace) {
            isFaceDetected = true

            let featureCenterX = feature.bounds.origin.x + feature.bounds.width / 2
            let featureCenterY = feature.bounds.origin.y + feature.bounds.height / 2

            self.faceDetectionFrameSize = imageDimensions.size
            self.faceSizeRatio = Double(feature.bounds.width) / Double(imageDimensions.width)
            self.facePositionRatioFromBottom = Double(featureCenterY / imageDimensions.height)

            var ratioFromLeft = Double(featureCenterX / imageDimensions.width)
            if CameraManager.shared.cameraPosition == .front {
                ratioFromLeft = 1 - ratioFromLeft
            }
            self.facePositionRatioFromLeft = ratioFromLeft
        }

        self.isFaceDetected = isFaceDetected
    }
}
