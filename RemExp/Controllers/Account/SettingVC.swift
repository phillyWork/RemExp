//
//  SettingVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/09.
//

import UIKit
import Firebase

final class SettingVC: UIViewController {
    
    //MARK: - Properties

    let dataManager = DataManager.shared
    
    //해결: delegate를 weak으로 선언 (2에서 약하게 가리키기)
    //weak: 무조건 class type만 가능 --> protocol을 class만 채택하도록 수정해야 함
    weak var delegate: UserDelegate?
    
    //AccountVC에서 넘어오는 User 데이터
    var user: User?
    
    private let nicknameEditTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = cellColor
        tf.textColor = viewTextColor
        tf.placeholder = "닉네임을 새로 입력해주세요"
        
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        return tf
    }()
    
//    private let passwordEditTextField: UITextField = {
//        let tf = UITextField()
//        tf.backgroundColor = cellColor
//        tf.textColor = viewTextColor
//        tf.isSecureTextEntry = true
//        tf.placeholder = "새로운 비밀번호를 입력해주세요"
//
//        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
//
//        return tf
//    }()
//
//    private let validatePasswordEdit: UITextField = {
//        let tf = UITextField()
//        tf.backgroundColor = cellColor
//        tf.textColor = viewTextColor
//        tf.isSecureTextEntry = true
//        tf.placeholder = "새로운 비밀번호 확인"
//
//        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
//
//        return tf
//    }()
//
//    private let validatePasswordErrorLabel: UILabel = {
//        let label = UILabel()
//        label.text = "입력한 비밀번호가 동일하지 않습니다."
//        label.textColor = UIColor.red
//        label.font = UIFont.systemFont(ofSize: 11)
//        return label
//    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수정완료", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = brandInactiveColor
        button.tintColor = viewTextColor
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(handleConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var withdrawalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("탈퇴하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.tintColor = .lightGray
        button.backgroundColor = cellColor
        
        button.addTarget(self, action: #selector(handleWithDrawl), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavController()
            
        //delegate
        nicknameEditTextField.delegate = self
//        passwordEditTextField.delegate = self

        configureUI()
    }
    
    private func configureNavController() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(handleCloseButton))
        navigationItem.leftBarButtonItem?.tintColor = viewTextColor
    }
    
    private func configureUI() {
        view.backgroundColor = viewBackgroundColor
        tabBarController?.tabBar.isHidden = true
        
//        let stackView = UIStackView(arrangedSubviews: [nicknameEditTextField, passwordEditTextField, validatePasswordEdit, validatePasswordErrorLabel])
        let stackView = UIStackView(arrangedSubviews: [nicknameEditTextField])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 200)
        

        let stackButtonView = UIStackView(arrangedSubviews: [confirmButton, withdrawalButton])
        stackButtonView.axis = .vertical
        stackButtonView.spacing = 10
        stackButtonView.distribution = .fillEqually
        
        view.addSubview(stackButtonView)
        stackButtonView.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 20, paddingRight: 10, width: 0, height: 106)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }

    
    //MARK: - Handlers
    
    //키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func handleCloseButton() {
        self.dismiss(animated: true)
    }
    
    @objc func formValidation() {
//        guard nicknameEditTextField.hasText, passwordEditTextField.hasText, validatePasswordEdit.hasText else {
        guard nicknameEditTextField.hasText else {
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = brandInactiveColor
            return
        }
        
        //password validation 체크
//        guard passwordEditTextField.text == validatePasswordEdit.text else {
//            validatePasswordErrorLabel.isHidden = false
//            return
//        }
//
//        validatePasswordErrorLabel.isHidden = true
        confirmButton.isEnabled = true
        confirmButton.backgroundColor = brandColor
    }
    
    
    @objc func handleConfirmButton() {
        //서버에 바뀐 nickname & password 저장
//        guard let newPassword = passwordEditTextField.text else { return }
        guard let newNickName = nicknameEditTextField.text else { return }
        
        let newUser = User(uid: self.user!.uid, email: self.user!.email, nickName: newNickName)
        delegate?.updateNickName(newUser)
        
        self.dismiss(animated: true)
        
        
//        //update password: needs to reauthenticate
//
//        guard let currentUser = Auth.auth().currentUser else { return }
//
//        let cred = EmailAuthProvider.credential(withEmail: currentUser.email, password: )
//
//        guard let cred = Auth.auth().emailprovider
//
//        await Auth.auth().currentUser?.reauthenticate(with: <#T##AuthCredential#>, completion: <#T##((AuthDataResult?, Error?) -> Void)?##((AuthDataResult?, Error?) -> Void)?##(AuthDataResult?, Error?) -> Void#>)
//
//        guard let currentUser = Auth.auth().currentUser else { return }
//        currentUser.updatePassword(to: newPassword) { error in
//            if let error = error {
//                print("Failed to update new password: \(error.localizedDescription)")
//                return
//            }
//            print("Succeed to update new password")
//            self.dismiss(animated: true)
//        }
        
    }
    
    @objc func handleWithDrawl() {
        //탈퇴시 alert로 탈퇴 입력 한번 더 받기
        let alert = UIAlertController(title: "탈퇴하기", message: "빈 칸에 '탈퇴하기'를 입력해주셔야 탈퇴가 완료됩니다.", preferredStyle: .alert)
        
        //입력창 textField 더하기
        alert.addTextField { (tf) in
            tf.placeholder = "'탈퇴하기'를 입력하세요"
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .default) { (_) in
            
            let textInput = alert.textFields?[0].text
            if textInput == "탈퇴하기" {
                //파이어베이스 유저 탈퇴
                guard let user = Auth.auth().currentUser else { return }
                user.delete { error in
                    //error happend
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    //db의 유저 데이터 삭제하기
                    self.dataManager.deleteUserData(uid: user.uid) { didSuccess in
                        switch didSuccess {
                        case true:
                            //탈퇴 완료 알림
                            let confirmAlert = UIAlertController(title: "탈퇴 완료", message: "이용해주셔서 감사합니다.", preferredStyle: .alert)
                            let confirm = UIAlertAction(title: "확인", style: .default) { error in
                                //loginVC 띄우기
                                let loginVC = LoginVC()
                                let navController = UINavigationController(rootViewController: loginVC)
                                navController.modalPresentationStyle = .fullScreen
                                self.present(navController, animated: true, completion: nil)
                            }
                            confirmAlert.addAction(confirm)
                            
                            DispatchQueue.main.async {
                                self.present(confirmAlert, animated: true)
                            }
                        case false:
                            let alert = UIAlertController(title: "탈퇴 실패", message: "계정 탈퇴에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                            let confirm = UIAlertAction(title: "확인", style: .default)
                            alert.addAction(confirm)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            } else {
                //입력 잘못됨 알림
                let differentAlert = UIAlertController(title: "입력 오류", message: "잘못 입력했습니다.", preferredStyle: .alert)
                let differentOk = UIAlertAction(title: "확인", style: .default)
                differentAlert.addAction(differentOk)
                
                DispatchQueue.main.async {
                    self.present(differentAlert, animated: true)
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true)
    }
    
    
}

//MARK: - TextFieldDelegate

extension SettingVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
