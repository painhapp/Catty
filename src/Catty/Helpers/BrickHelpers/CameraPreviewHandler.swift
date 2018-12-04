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

@objc
class CameraPreviewHandler: NSObject {

    @objc
    public static let shared = CameraPreviewHandler()
    private var camView: UIView?
    var camLayer: CALayer?

    override init() {
        super.init()
    }

    @objc
    func setCamView(_ camView: UIView?) {
        if camView != nil {
            self.camView = camView
        }
        if CameraManager.shared.session.isRunning {
            stopCamera()
            startCameraPreview()
        }
    }

    func startCameraPreview() {
        CameraManager.shared.start()
        setCameraPreview()
    }

    @objc
    func stopCamera() {
        if camLayer != nil {
            camLayer?.removeFromSuperlayer()
        }
        CameraManager.shared.stop()
    }

    func switchCameraPosition(position: AVCaptureDevice.Position) {
        CameraManager.shared.cameraPosition = position
    }

    func setCameraPreview() {
        assert(camView != nil)

        camLayer = CALayer()
        camLayer?.accessibilityHint = "camLayer"
        camLayer?.frame = camView?.bounds ?? CGRect.zero
        camView?.backgroundColor = UIColor.white
        if let aLayer = camLayer {
            camView?.layer.insertSublayer(aLayer, at: 0)
        }

        CameraManager.shared.setPreview(layer: camLayer!)
    }
}
