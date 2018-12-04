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
class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    @objc
    public static let shared = CameraManager(session: AVCaptureSession(), cameraPosition: AVCaptureDevice.Position.front)

    private var _session: AVCaptureSession?
    @objc var session: AVCaptureSession {
        set { _session = newValue }
        get { return _session! }
    }
    private var _cameraPosition: AVCaptureDevice.Position?
    @objc var cameraPosition: AVCaptureDevice.Position {
        set {
            if session.isRunning {
                self.stop()
                _cameraPosition = newValue
                self.start()
            } else {
                _cameraPosition = newValue
            }
        }
        get { return _cameraPosition! }
    }

    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - init

    init(session: AVCaptureSession, cameraPosition: AVCaptureDevice.Position) {
        super.init()
        self.session = session
        self.cameraPosition = cameraPosition
    }

    @objc
    func reset() {
        self.cameraPosition = AVCaptureDevice.Position.front
        self.session = AVCaptureSession()
        self.videoDataOutput = AVCaptureVideoDataOutput()
    }

    @objc
    func start() {
        //self.reset()
        guard let device = camera(for: cameraPosition),
            let deviceInput = try? AVCaptureDeviceInput(device: device)
            else { return }

        if session.isRunning {
            session.stopRunning()
        }

        session.beginConfiguration()
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }

        self.videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput!.videoSettings = [ kCVPixelBufferPixelFormatTypeKey: kCMPixelFormat_32BGRA ] as [String: Any]
        videoDataOutput!.alwaysDiscardsLateVideoFrames = false

        // create a serial dispatch queue used for the sample buffer delegate
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.videoDataOutput != nil {
                self.videoDataOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "BufferOutput.queue"))
            }
        }

        if session.canAddOutput(videoDataOutput!) {
            self.session.addOutput(videoDataOutput!)
        }

        let videoDataOutputConnection = videoDataOutput!.connection(with: .video)
        videoDataOutputConnection?.isEnabled = true

        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer?.backgroundColor = UIColor.black.cgColor
        self.previewLayer?.videoGravity = .resizeAspect
        self.previewLayer?.isHidden = true
        session.commitConfiguration()
        session.startRunning()
    }

    @objc
    func stop() {
        /*if let inputs = self.session.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.session.removeInput(input)
            }
        }
        if let outputs = self.session.outputs as? [AVCaptureVideoDataOutput] {
            for output in outputs {
                self.session.removeOutput(output)
            }
        }

        self.session.stopRunning()
        self.videoDataOutput?.connection(with: .video)?.isEnabled = false
        self.videoDataOutput = nil
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = nil*/
    }

    func available() -> Bool {
        guard let device = camera(for: cameraPosition),
            let _ = try? AVCaptureDeviceInput(device: device) else { return false }
        return true
    }

    @objc
    func setPreview(layer: CALayer) {
        layer.masksToBounds = true
        if previewLayer != nil {
            previewLayer!.frame = layer.bounds
            previewLayer!.isHidden = false
            layer.addSublayer(previewLayer!)
        }
    }

    // MARK: -

    func camera(for cameraPosition: AVCaptureDevice.Position) -> AVCaptureDevice? {
        for device in AVCaptureDevice.devices(for: .video) where (device.position == cameraPosition) {
            return device
        }
        return nil
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: attachments as? [String: Any])

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CaptureOutputCatty"), object: ciImage)
    }
}
