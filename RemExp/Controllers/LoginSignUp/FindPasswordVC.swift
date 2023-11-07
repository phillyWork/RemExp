//
//  FindPasswordVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/11.
//

import UIKit
import Firebase

final class FindPasswordVC: UIViewController {

    //MARK: - Properties
    
    //logoContainerView
    private let logoContainerView: UIView = {
        let view = UIView()
        
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .scaleAspectFill
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.backgroundColor = brandColor
        
        return view
    }()
    
    //welcome text, input textfields, login-button
    private let infoText: UILabel = {
        let label = UILabel()
        label.text = "가입한 이메일을 입력해주세요"
        label.textColor = viewTextColor
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이메일"
        tf.backgroundColor = cellColor
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = viewTextColor
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()

    private lazy var findPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("비밀번호 찾기", for: .normal)
        button.setTitleColor(viewTextColor, for: .normal)
        button.backgroundColor = brandInactiveColor
        button.addTarget(self, action: #selector(handlePasswordButton), for: .touchUpInside)
        button.isEnabled = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    //button to find password
    private lazy var rememberPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "비밀번호가 기억나시나요?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "로그인하기", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: blueButtonColor]))
        
        button.addTarget(self, action: #selector(handleBackToLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()
    
    //MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        emailTextField.delegate = self
        
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = viewBackgroundColor
        
        navigationController?.navigationBar.isHidden = true
        
        //logoContainerView
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        //stackView for buttons and textfields
        let stackView = UIStackView(arrangedSubviews: [infoText, emailTextField, findPasswordButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 150)
        
        view.addSubview(rememberPasswordButton)
        rememberPasswordButton.anchor(top: stackView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)

    }
    
    //MARK: - Handlers
    
    //키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @objc func formValidation() {
        guard emailTextField.hasText else {
            findPasswordButton.isEnabled = false
            findPasswordButton.backgroundColor = brandInactiveColor
            return
        }
        
        findPasswordButton.isEnabled = true
        findPasswordButton.backgroundColor = brandColor
    }
    
    
    //email에 validation 메일 보내기
    //validation 어떻게 처리할 지 고민
    
    @objc func handlePasswordButton() {
        //로그인하기 버튼 숨기기
        rememberPasswordButton.isHidden = true
        
        guard let email = emailTextField.text else { return }
        
        //비밀번호 재설정 이메일 보내기
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                let alert = UIAlertController(title: "실패", message: "이메일 입력이 잘못되었습니다.\n다시 입력해주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default) { action in
                    print("error: \(error.localizedDescription)")
                    return
                }
                alert.addAction(action)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
            
            print("Sent to email: ", email)
            
            let emailAlert = UIAlertController(title: "이메일 전송", message: "이메일에서 링크를 눌러 비밀번호를 재설정하세요.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default) { action in
                self.navigationController?.popViewController(animated: true)
            }
            
            emailAlert.addAction(action)
            DispatchQueue.main.async {
                self.present(emailAlert, animated: true)
            }
            
        }
        
    }
    
    @objc func handleBackToLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - TextFieldDelegate

extension FindPasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
