//
//  LoginVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore

import GoogleSignIn

import AuthenticationServices
import CryptoKit

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

fileprivate var currentNonce: String?

final class LoginVC: UIViewController {
    
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
    
    private let welcomeText: UILabel = {
        let label = UILabel()
        label.text = "환영합니다!"
        label.textColor = viewTextColor
        label.font = UIFont.boldSystemFont(ofSize: 16)
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
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호"
        tf.backgroundColor = cellColor
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = viewTextColor
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(viewTextColor, for: .normal)
        button.backgroundColor = brandInactiveColor
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    //button to find password
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "비밀번호를 잊으셨나요?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "비밀번호 찾기", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: blueButtonColor]))
        
        button.addTarget(self, action: #selector(handlePasswordFindOut), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()
    
    
    //social login buttons
    private let socialLoginContainer: UIView = {
        let view = UIView()
        view.backgroundColor = viewBackgroundColor
        return view
    }()
    
    private let orText: UILabel = {
        let label = UILabel()
        label.text = "소셜 로그인으로 시작하기"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = viewTextColor
        return label
    }()
    
    private lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.backgroundColor = viewBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        
        button.colorScheme = .light
        button.style = .wide
        
        button.addTarget(self, action: #selector(signInGoogle), for: .touchUpInside)

        return button
    }()
    
    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        button.backgroundColor = viewBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5

        button.addTarget(self, action: #selector(signInApple), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var kakaoSignInButton: UIButton = {
        let button = UIButton()
        button.setImage(kakaoButtonImage, for: .normal)
        button.contentMode = .scaleAspectFill
        button.backgroundColor = viewBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
                
        button.addTarget(self, action: #selector(signInKakao), for: .touchUpInside)
        
        return button
    }()
    

    //button for signup
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "계정이 없으신가요?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "회원가입", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: blueButtonColor]))
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()
    
    
    //MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = viewBackgroundColor
        
        navigationController?.navigationBar.isHidden = true
        
        //logoContainerView
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        //stackView for buttons and textfields
        let stackView = UIStackView(arrangedSubviews: [welcomeText, emailTextField, passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 180)
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.anchor(top: stackView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        //signup button
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        
        //social login buttons
        view.addSubview(socialLoginContainer)
        socialLoginContainer.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: dontHaveAccountButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 15, paddingRight: 20, width: 0, height: 160)
        
        socialLoginContainer.addSubview(orText)
        orText.anchor(top: socialLoginContainer.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        orText.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        let socialStack = UIStackView(arrangedSubviews: [appleSignInButton, googleSignInButton, kakaoSignInButton])
        socialStack.spacing = 5
        socialStack.axis = .vertical
        socialStack.distribution = .fillEqually
        
        socialLoginContainer.addSubview(socialStack)
        socialStack.anchor(top: orText.bottomAnchor, left: socialLoginContainer.leftAnchor, bottom: socialLoginContainer.bottomAnchor, right: socialLoginContainer.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 130)
    }
    
    private func startApp() {
        //display the app's main content View.
        guard let mainTabVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }
        //configure VC in mainTabVC
        mainTabVC.configureVC()
        //dismiss loginVC
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Handlers
    
    //키보드 내려가기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc func formValidation() {
        guard emailTextField.hasText, passwordTextField.hasText else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = brandInactiveColor
            return
        }
        
        loginButton.isEnabled = true
        loginButton.backgroundColor = brandColor
    }
    
    private func handleErrorCodes(error: NSError) -> String {
        //에러 종류따라 메세지 다르게 (Switch 활용)
        let errorCode = AuthErrorCode.Code(rawValue: error.code)
        // 에러 코드에 대한 안내 문구 반환하기
        // 사전 유효성 검증 여부 등을 고려해 발생 빈도 순으로 분기처리
        switch errorCode {
        case .userNotFound:
            return "이메일 혹은 비밀번호가 일치하지 않습니다."
        case .wrongPassword:
            return "이메일 혹은 비밀번호가 일치하지 않습니다."
        case .weakPassword:
            return "비밀번호는 6글자 이상이어야 합니다."
        case .webNetworkRequestFailed:
            return "네트워크 연결에 실패했습니다."
        case .invalidEmail:
            return "잘못된 이메일 형식입니다."
        case .internalError:
            return "잘못된 요청입니다."
          default:
            return "로그인에 실패 하였습니다."
        }
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                
                let message = self.handleErrorCodes(error: error as NSError)
                
                let alert = UIAlertController(title: "로그인에 실패했습니다.", message: message, preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default)
                alert.addAction(confirm)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
                return
            }
            self.startApp()
        }
    }
    
    @objc func handlePasswordFindOut() {
        let findPasswordVC = FindPasswordVC()
        navigationController?.pushViewController(findPasswordVC, animated: true)
    }
    
    
    
    //social login
    @objc func signInGoogle() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print("Error with sign in Google")
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    let alert = UIAlertController(title: "로그인에 실패했습니다.", message: "구글 연동에 실패했습니다.", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(confirm)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                    return
                }
                self.startApp()
            }
        }
    
    }
    
    @objc func signInApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        // request 요청을 했을 때 none가 포함되어서 릴레이 공격을 방지
        // 추후 파베에서도 무결성 확인을 할 수 있게끔 함
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    @objc func signInKakao() {
        //token 확인
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { accessTokenInfo, error in
                if let error = error {
                    print("토큰 접근 불가: \(error.localizedDescription)")
                    //토큰 갱신하기: 새로 로그인하기
                    self.kakaoLogin()
                } else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    print("토큰 접근 가능")
                    
                    self.kakaoLogin()
                }
            }
        } else {
            //token 존재하지 않음, 새로 로그인하기
            kakaoLogin()
        }
    }
    
    private func kakaoLogin() {
        // 카카오톡 실행 가능 여부 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            //카카오톡으로 로그인하기
            kakaoLoginInApp()
        } else {
            //웹으로 카카오 로그인하기
            kakaoLoginInWeb()
        }
    }
    
    //카카오 인증 서버에 사용자 정보를 가져오기 위해 토큰 발급을 요청합니다.
    //토큰을 발급 받으면 토큰과 함께 사용자 정보를 요청합니다. (이메일, userID)
    //토큰 검증 완료 후 사용자 정보를 제공받습니다.
    
    private func kakaoLoginInApp() {
        UserApi.shared.loginWithKakaoTalk() { (oauthToken, error) in
            if let error = error {
                print("카카오톡 로그인 에러: \(error.localizedDescription)")
            } else {
                print("카카오톡 로그인 성공")
                guard let token = oauthToken else { return }
                self.loginFirebase(token)
            }
        }
    }
    
    private func kakaoLoginInWeb() {
        UserApi.shared.loginWithKakaoAccount(prompts: [.Login]) { oauthToken, error in
            if let error = error {
                print("카카오 계정 로그인 에러: \(error.localizedDescription)")
            } else {
                print("카카오 계정 로그인 성공")
                guard let token = oauthToken else { return }
                self.loginFirebase(token)
            }
        }
    }
    
    
    private func loginFirebase(_ token: OAuthToken) {
        //파이어베이스 인증 서버에 회원가입 및 로그인을 완료합니다.
        //로그인 여부를 확인합니다.
        
        UserApi.shared.me { user, error in
            if let error = error {
                print("사용자 정보 가져오기 에러: \(error.localizedDescription)")
            } else {
                print("사용자 정보 가져오기 성공")
                
                guard let user = user else { return }
                let password = "\(String(describing: user.id))"
                guard let email = user.kakaoAccount?.email else { return }
                
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        let alert = UIAlertController(title: "로그인에 실패했습니다.", message: "카카오 로그인에 실패했습니다.", preferredStyle: .alert)
                        let confirm = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(confirm)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                        return
                    }
                    self.startApp()
                }
            }
        }
    }

    @objc func handleShowSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
}

//MARK: - ASAuthorizationControllerDelegate

extension LoginVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 안전하게 인증 정보를 전달하기 위해 nonce 사용
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // token들로 credential을 구성해서 auth signin 구성 (google과 동일)
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    let alert = UIAlertController(title: "로그인에 실패했습니다.", message: "애플 연동에 실패했습니다.", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(confirm)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                    return
                }
            
                // User is signed in to Firebase with Apple.
                self.startApp()
            }
        }
    }
    
}

//MARK: - ASAuthorizationControllerPresentationContextProviding

extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


//MARK: - TextFieldDelegate

extension LoginVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
