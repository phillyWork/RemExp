//
//  CameraVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/09.
//

import UIKit
import AVFoundation

final class CameraVC: UIViewController {
    
    //MARK: - Properties
    
    let dataManager = DataManager.shared
    
    //delegate for getting Product from CameraVC
    weak var productFromBarcodeDelegate: GetProductFromBarcodeDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    //barcode types
    let metaDataObjectTypes: [AVMetadataObject.ObjectType] = [
        .upce,
        .code39,
        .code39Mod43,
        .code93,
        .code128,
        .ean8,
        .ean13,
        .aztec,
        .pdf417,
        .itf14,
        .dataMatrix,
        .interleaved2of5,
        .qr,
    ]
    
    //MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = viewBackgroundColor
        checkAuthorization()
    }
       

    //MARK: - Privacy Camera Authrization
    
    private func checkAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            setBarcodeReader()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { isSuccess in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.setBarcodeReader()
                    }
                } else {
                    let alert = UIAlertController(title: "알림", message: "바코드 촬영을 위해 카메라 권한이 필요합니다.\n설정 > 어플리케이션에서 카메라 권한을 허용으로 변경해주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                }
            }
        default:
            let alert = UIAlertController(title: "알림", message: "바코드 촬영을 위해 카메라 권한이 필요합니다.\n설정 > 어플리케이션에서 카메라 권한을 허용으로 변경해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    
    
    private func setBarcodeReader() {
        
        self.captureSession = AVCaptureSession()
            
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

        let input: AVCaptureDeviceInput
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error {
            print("error occurred during camera: \(error.localizedDescription)")
            return
        }
        
        guard let captureSession = self.captureSession else {
            print("Failed captureSession")
            self.fail()
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            print("Can't add input into captureSession")
            self.fail()
            return
        }
                
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = self.metaDataObjectTypes
        } else {
            print("Can't add output into captureSession")
            self.fail()
            return
        }
        
        setPreviewLayer()
        setCenterGuideLineView()
       
        self.start()
    }
    
    private func setPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.layer.addSublayer(previewLayer!)
    }
            
    private func setCenterGuideLineView() {
        let centerGuideLineView = UIView()
        centerGuideLineView.translatesAutoresizingMaskIntoConstraints = false
        centerGuideLineView.backgroundColor = #colorLiteral(red: 1, green: 0.671867907, blue: 0.3106851578, alpha: 1)

        view.addSubview(centerGuideLineView)
        view.bringSubviewToFront(centerGuideLineView)

        centerGuideLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        centerGuideLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        centerGuideLineView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerGuideLineView.heightAnchor.constraint(equalToConstant: 3).isActive = true
    }

}

//MARK: - AVCaptureMetadataOutputObjectsDelegate

extension CameraVC: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        print("# GET metadataOutput")
        self.stop()
        
        if metadataObjects.count == 0 {
            print("Nothing to show")
            return
        }

        let metaDataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        guard let StringCodeValue = metaDataObject.stringValue else {
            print("Can't get string value from metadataObject")
            return
        }

        guard let _ = self.previewLayer?.transformedMetadataObject(for: metaDataObject) else {
            print("Can't get transformed data from metadataObject")
            return
        }

        self.found(barcodeFromCamera: StringCodeValue)
    }

}

//MARK: - Extension for AVCaptureDevice

extension CameraVC {
    func start() {
        print("captureSession starts running")
        DispatchQueue.global().async {
            self.captureSession?.startRunning()
        }
    }
    
    func stop() {
        print("captureSession stops running")
        self.captureSession?.stopRunning()
    }
    
    func fail() {
        print("captureSession failed")
        let alert = UIAlertController(title: "오류", message: "바코드를 인식하지 못했습니다.\n다시 시도해주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func found(barcodeFromCamera: String) {
        print("Found barcode value: \(barcodeFromCamera)")
        
        //query DB's Products collection with barcode, pass the result to make Product instance
        dataManager.queryProductFromDB(barcode: barcodeFromCamera) { product in
            if let productFromDB = product {
                let alert = UIAlertController(title: "성공", message: "제품을 확인했습니다.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default) { action in
                    self.productFromBarcodeDelegate?.updateUI(productFromDB)
                    self.dismiss(animated: true)
                }
                alert.addAction(action)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "실패", message: "제품을 확인할 수 없습니다. 직접 입력해주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default) { action in
                    self.dismiss(animated: true)
                }
                alert.addAction(action)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
        
        
    }
    
}
