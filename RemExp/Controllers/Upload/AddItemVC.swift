//
//  AddItemVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit
import Firebase
import FirebaseAuth

final class AddItemVC: UIViewController {

    //MARK: - Properties
    
    let dataManager = DataManager.shared
    
    //AddItemVC에서 넘어온 경우, existUserProduct가 nil
    //ItemVC에서 넘어온 경우, 기존 아이템 수정 --> 정보 받아와야 함
    //didSet으로 확인
    var existUserProduct: UserProduct? {
        didSet {
            setupExistingUserProduct()
        }
    }

    //CameraVC로부터 바코드 정보로 얻은 Product 받아오기 by delegate
    var productFromDB: Product?

    //delegate for updating UserProduct to ItemVC
    weak var updateUserProductDelegate: UpdateItemDelegate?
    
    private let categoryTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "카테고리"
        tf.backgroundColor = cellColor
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = viewTextColor
        
        tf.addTarget(self, action: #selector(formValidation), for: .allEditingEvents)
        
        return tf
    }()
    
    private let brandTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "브랜드"
        tf.backgroundColor = cellColor
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = viewTextColor
        
        tf.addTarget(self, action: #selector(formValidation), for: .allEditingEvents)
        
        return tf
    }()
    
    private let productTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이름"
        tf.backgroundColor = cellColor
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = viewTextColor
        
        //for checking input condition
        tf.addTarget(self, action: #selector(formValidation), for: .allEditingEvents)
        
        return tf
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        
        //locale 설정: 한국
        picker.locale = Locale(identifier: "ko_KR")
        picker.calendar.locale = Locale(identifier: "ko_KR")
        //현재 시간으로 자동 업데이트
        picker.timeZone = .autoupdatingCurrent
        //달력 설정
        picker.datePickerMode = .date
        
        picker.tintColor = viewTextColor
        picker.backgroundColor = cellColor
        
        return picker
    }()
    
    //camera button
    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("바코드 스캔하기", for: .normal)
        button.setTitleColor(viewTextColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = cellColor
        button.layer.cornerRadius = 5
        
        button.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
        
        return button
    }()
    
    //confirm button
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("결정", for: .normal)
        button.setTitleColor(viewTextColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = brandInactiveColor
        button.layer.cornerRadius = 5
        
        //default: button is disabled
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureNavController()
        
        //delegate
        categoryTextField.delegate = self
        brandTextField.delegate = self
        productTextField.delegate = self
        
        configureUI()
    }
    
    private func configureNavController() {
        
        navigationItem.title = "상품 정보"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(handleCloseButton))
        navigationItem.leftBarButtonItem?.tintColor = viewTextColor
    }
    
    private func configureUI() {
        view.backgroundColor = viewBackgroundColor
        
        view.addSubview(categoryTextField)
        categoryTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 76)
        
        view.addSubview(brandTextField)
        brandTextField.anchor(top: categoryTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 76)
        
        view.addSubview(productTextField)
        productTextField.anchor(top: brandTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 76)
        
        view.addSubview(datePicker)
        datePicker.anchor(top: productTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 76)
        
        view.addSubview(confirmButton)
        confirmButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 48)
        
        view.addSubview(cameraButton)
        cameraButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: confirmButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 48)
        
    }
    
    //MARK: - Handlers
    
    //키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func formValidation() {
        guard categoryTextField.hasText, brandTextField.hasText, productTextField.hasText else {
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = brandInactiveColor
            return
        }
        
        confirmButton.isEnabled = true
        confirmButton.backgroundColor = brandColor
    }
    
    @objc func handleCloseButton() {
        self.dismiss(animated: true)
    }
    
    @objc func handleCamera() {
        let cameraVC = CameraVC()
        cameraVC.productFromBarcodeDelegate = self
        present(cameraVC, animated: true)
    }
    
    @objc func handleConfirm() {
        //data 서버에 저장
        
        //기존 아이템인지 신규 아이템인지 구분: uuid 존재여부
        //uuid 존재: 기존 정보에 수정된 것만 다시 저장
        //uuid 없음: 신규, 새로 저장
        
        //barcode 인식 O: DB에 있다면 Product에서 가져다 활용
        //barcode 인식 X or 안함(직접 입력): Product 가져다 쓰지 않음, default image로 등록
        
        //기존 data 경우
        if existUserProduct != nil {
            print("It's going to update existing userProduct")
            guard let existProduct = existUserProduct else {
                print("There's nothing in existProduct")
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let category = categoryTextField.text, let brand = brandTextField.text, let name = productTextField.text else { return }
            let updatedProduct = Product(barcode: existProduct.product.barcode, brandName: brand, productName: name, category: category, imageUrl: existProduct.product.imageUrl)
            let expiresAt = datePicker.date
            let updatedUserProduct = UserProduct(uid: existProduct.uid, isUsed: existProduct.isUsed, createdAt: existProduct.createdAt, expiresAt: expiresAt, product: updatedProduct)
            
            dataManager.uploadDataToDB(uid: uid, uidForUserProduct: existProduct.uid, userProduct: updatedUserProduct, isUpdate: true) { result in
                switch result {
                case false:
                    print("updating document to DB failed")
                    
                    let alert = UIAlertController(title: "실패", message: "정보 수정에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                case true:
                    print("updating document to DB succeed")
                    
                    let alert = UIAlertController(title: "완료", message: "정보 수정이 완료되었습니다.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default) { action in
                        //view 닫기 with updated UserProduct
                        self.updateUserProductDelegate?.didUpdateItem(updatedUserProduct)
                        self.dismiss(animated: true)
                    }
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        //신규 data 경우
        else {
            print("It's going to upload new userProduct")
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let uidForUserProduct = UUID().uuidString
            guard let category = categoryTextField.text, let brand = brandTextField.text, let name = productTextField.text else { return }
            let createdAt = Date.now
            let expiresAt = datePicker.date
            
            var newProduct: Product?
            if let existProduct = productFromDB {
                //barcode로 받아온 product 존재 시
                newProduct = Product(barcode: existProduct.barcode, brandName: brand, productName: name, category: category, imageUrl: existProduct.imageUrl)
                
                let newUserProduct: UserProduct = UserProduct(uid: uidForUserProduct, isUsed: false, createdAt: createdAt, expiresAt: expiresAt, product: newProduct!)
                
                //upload newUserProduct
                dataManager.uploadDataToDB(uid: uid, uidForUserProduct: uidForUserProduct, userProduct: newUserProduct, isUpdate: false) { result in
                    switch result {
                    case false:
                        print("uploadDataToDB failed")
                        
                        let alert = UIAlertController(title: "실패", message: "제품 등록에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(action)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    case true:
                        print("uploadDataToDB succeed")
                        
                        let alert = UIAlertController(title: "완료", message: "제품 등록이 완료되었습니다.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default) { action in
                            //view 닫기
                            self.dismiss(animated: true)
                        }
                        alert.addAction(action)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    }
                }
                
            } else {
                //DB에 product 존재 하지 않아서 유저가 직접 등록하는 경우
                //storage의 default image 활용
                STORAGE_PRODUCTS_REF.child("defaultImage.jpg").downloadURL { url, error in
                    if let error = error {
                        print("error with downloading url: \(error.localizedDescription)")
                        return
                    }
                    
                    //image url
                    guard let postImageUrl = url?.absoluteString else {
                        print("Can't get url from storage")
                        return
                    }
                    
                    print("imageUrl: ", postImageUrl)
                    newProduct = Product(barcode: "", brandName: brand, productName: name, category: category, imageUrl: postImageUrl)
                    
                    let newUserProduct: UserProduct = UserProduct(uid: uidForUserProduct, isUsed: false, createdAt: createdAt, expiresAt: expiresAt, product: newProduct!)
                    
                    //upload newUserProduct
                    self.dataManager.uploadDataToDB(uid: uid, uidForUserProduct: uidForUserProduct, userProduct: newUserProduct, isUpdate: false) { result in
                        switch result {
                        case false:
                            print("uploadDataToDB failed")
                            
                            let alert = UIAlertController(title: "실패", message: "제품 등록에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default)
                            alert.addAction(action)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true)
                            }
                        case true:
                            print("uploadDataToDB succeed")
                            
                            let alert = UIAlertController(title: "완료", message: "제품 등록이 완료되었습니다.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default) { action in
                                //view 닫기
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
        }
    }
    
    
    //MARK: - API
    
    private func setupExistingUserProduct() {
        print("UserProduct data from ItemVC moved to AddItemVC")
    
        //setup category, brand, product from existUserProduct
        DispatchQueue.main.async {
            self.categoryTextField.text = self.existUserProduct?.product.category
            self.brandTextField.text = self.existUserProduct?.product.brandName
            self.productTextField.text = self.existUserProduct?.product.productName
            self.datePicker.date = self.existUserProduct!.expiresAt
        }
    }
        
}

//MARK: - TextFieldDelegate

extension AddItemVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

//MARK: - GetProductFromBarcodeDelegate

extension AddItemVC: GetProductFromBarcodeDelegate {
    
    func updateUI(_ product: Product) {
        print("Product got from Barcode from CameraVC moved to AddItemVC")
        self.productFromDB = product
        
        //UI에 적용하기
        DispatchQueue.main.async {
            self.categoryTextField.text = self.productFromDB?.category
            self.brandTextField.text = self.productFromDB?.brandName
            self.productTextField.text = self.productFromDB?.productName
        }
        
    }

}
