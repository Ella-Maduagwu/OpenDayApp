import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the capture session
        captureSession = AVCaptureSession()

        // Set up the camera as an input device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Unable to access the camera")
            return
        }
        
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error creating video input: \(error)")
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("Failed to add video input to the session")
            return
        }

        // Set up the output for detecting QR codes
        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Failed to add metadata output to the session")
            return
        }

        // Set up the camera preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start the capture session
        captureSession.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
    }

    // Delegate method that is called when a QR code is found
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }

    // Handle the QR code content
    func found(code: String) {
        print("DEBUG: Found QR Code: \(code)")
        // Use the code value to navigate or update UI
        handleQRCodeScanningResult(qrCode: code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // Custom function to handle navigation or further processing
    func handleQRCodeScanningResult(qrCode: String) {
        // Navigate to the appropriate screen or display information
        // Assume qrCode contains room name or unique identifier
        let roomsVC = storyboard?.instantiateViewController(withIdentifier: "RoomsViewController") as! RoomsViewController
        roomsVC.buildingName = qrCode // Set the building or room name
        navigationController?.pushViewController(roomsVC, animated: true)
    }
}
