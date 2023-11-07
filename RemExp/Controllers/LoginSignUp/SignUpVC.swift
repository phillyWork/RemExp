//
//  SignUpVC.swift
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

final class SignUpVC: UIViewController {
    
    //MARK: - Properties
    
    let dataManager = DataManager.shared
    
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
    
    //welcome text, input textfields, signup-button
    private let signUpText: UILabel = {
        let label = UILabel()
        label.text = "계정을 만들어보세요"
        label.font = UIFont.boldSystemFont(ofSize: 14)
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
        tf.isSecureTextEntry = true                             //secure text entry, disable capitalization
        tf.backgroundColor = cellColor
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = viewTextColor
        
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        return tf
    }()

    private let validatePasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호 확인"
        tf.isSecureTextEntry = true
        tf.backgroundColor = cellColor
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = viewTextColor
        
        //for checking input condition
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        return tf
    }()
    
    private let validatePasswordErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "입력한 비밀번호가 동일하지 않습니다."
        label.textColor = UIColor.red
        label.font = UIFont.boldSystemFont(ofSize: 11)
        return label
    }()
    
    private let nickNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "닉네임"
        tf.backgroundColor = cellColor
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = viewTextColor
        
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        return tf
    }()
    
    //signup button
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("계정 생성", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(viewTextColor, for: .normal)
        button.backgroundColor = brandInactiveColor
        button.layer.cornerRadius = 5       //corner is rounded
        
        //default: button is disabled
        button.isEnabled = false
        
        //signing functionality
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
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
    
    private lazy var googleSignUpButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.backgroundColor = viewBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        
        button.colorScheme = .light
        button.style = .wide
        
        button.addTarget(self, action: #selector(signUpGoogle), for: .touchUpInside)

        return button
    }()
    
    private lazy var appleSignUpButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signUp, style: .whiteOutline)
        button.backgroundColor = viewBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5

        button.addTarget(self, action: #selector(signUpApple), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var kakaoSignUpButton: UIButton = {
        let button = UIButton()
        button.setImage(kakaoButtonImage, for: .normal)
        button.contentMode = .scaleAspectFill
        button.backgroundColor = viewBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5

        button.addTarget(self, action: #selector(signUpKakao), for: .touchUpInside)

        return button
    }()
    
    
    //"back to login" button at bottom
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        //use attributed button
        //whole button, even though texts are different in color and boldness
        let attributedTitle = NSMutableAttributedString(string: "이미 계정이 있으신가요?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        //add another string into button with different color and boldness
        attributedTitle.append(NSAttributedString(string: "로그인하기", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: blueButtonColor]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nickNameTextField.delegate = self
        validatePasswordTextField.delegate = self
        
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = viewBackgroundColor
        navigationController?.navigationBar.isHidden = true
            
        //logoContainerView
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        //stackView for buttons and textfields
        let stackView = UIStackView(arrangedSubviews: [signUpText, emailTextField, passwordTextField, validatePasswordTextField])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 150)
    
        view.addSubview(validatePasswordErrorLabel)
        validatePasswordErrorLabel.anchor(top: stackView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        let createUserStack = UIStackView(arrangedSubviews: [nickNameTextField, signUpButton])
        createUserStack.axis = .vertical
        createUserStack.spacing = 5
        createUserStack.distribution = .fillEqually
        
        view.addSubview(createUserStack)
        createUserStack.anchor(top: validatePasswordErrorLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 60)
        
//        view.addSubview(nickNameTextField)
//        nickNameTextField.anchor(top: validatePasswordErrorLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
//
//        //signup button
//        view.addSubview(signUpButton)
//        signUpButton.anchor(top: nickNameTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
        
        
        //already have account button
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        
        //social login button
        view.addSubview(socialLoginContainer)
        socialLoginContainer.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: alreadyHaveAccountButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 15, paddingRight: 20, width: 0, height: 160)
        
        socialLoginContainer.addSubview(orText)
        orText.anchor(top: socialLoginContainer.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        orText.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        let socialStack = UIStackView(arrangedSubviews: [appleSignUpButton, googleSignUpButton, kakaoSignUpButton])
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
        guard emailTextField.hasText, passwordTextField.hasText else { return }

        guard validatePasswordTextField.hasText else {
            validatePasswordErrorLabel.isHidden = false
            return
        }
        
        //password validation 체크
        guard passwordTextField.text == validatePasswordTextField.text else {
            validatePasswordErrorLabel.isHidden = false
            return
        }
        
        validatePasswordErrorLabel.isHidden = true
  
        guard nickNameTextField.hasText else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = brandInactiveColor
            return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = brandColor
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
        case .emailAlreadyInUse:
            return "이미 사용 중인 이메일입니다."
        case .weakPassword:
            return "비밀번호는 6글자 이상이어야 합니다."
        case .webNetworkRequestFailed:
            return "네트워크 연결에 실패했습니다."
        case .invalidEmail:
            return "잘못된 이메일 형식입니다."
        case .internalError:
            return "잘못된 요청입니다."
          default:
            return "계정 생성에 실패 하였습니다."
        }
    }

    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let confirmPassword = validatePasswordTextField.text else { return }
        guard let nickName = nickNameTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if let error = error {
                let message = self.handleErrorCodes(error: error as NSError)
                
                let alert = UIAlertController(title: "오류 발생", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default)
                
                alert.addAction(action)
                
                self.present(alert, animated: true)
                return
            }
        
            guard let uid = user?.user.uid else { return }
            
            //save user info to database (same as update user data into database)
            self.dataManager.queryDuplicateUserData(uid: uid, email: email, nickName: nickName) { result in
                switch result {
                case true:
                    let alert = UIAlertController(title: "성공", message: "유저 등록에 성공했습니다.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default) { action in
                        //start the app
                        self.startApp()
                    }
                    alert.addAction(action)
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                case false:
                    let alert = UIAlertController(title: "실패", message: "유저 등록에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(action)
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func signUpGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Can't get clientID")
            return
        }
        print("clientID: ", clientID)
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print("Error with sign up Google: \(error?.localizedDescription)")
                return
            }
            
            print("Google SignIn success!")
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("Can't get user or token")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error with sign in with firebase: \(error.localizedDescription)")
                    return
                }
                
                guard let result = result else {
                    print("Can't get result from signin with credential")
                    return
                }
                
                //get email from token
                guard let email = result.user.email else {
                    print("Can't get email from result")
                    return
                }
                //uid
                let uid = result.user.uid
                let nickName = "구글"
                
                print("email: \(email), uid: \(uid), nickName: \(nickName)")
                
                self.dataManager.queryDuplicateUserData(uid: uid, email: email, nickName: nickName) { result in
                    switch result {
                    case true:
                        let alert = UIAlertController(title: "성공", message: "유저 등록에 성공했습니다.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default) { action in
                            //start the app
                            self.startApp()
                        }
                        alert.addAction(action)
                        
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    case false:
                        let alert = UIAlertController(title: "실패", message: "유저 등록에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(action)
                        
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @objc func signUpApple() {
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
    
    @objc func signUpKakao() {
        //token 확인
        if AuthApi.hasToken() {
            //hasToken()의 결과가 true라도 현재 사용자가 로그인 상태임을 보장하지 않습니다
            UserApi.shared.accessTokenInfo { accessTokenInfo, error in
                if let error = error {
                    print("토큰 접근 불가: \(error.localizedDescription)")
                    //토큰 갱신하기: 새로 로그인하기
                    self.kakaoLogin()
                } else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    print("토큰 접근 가능")
                    //토큰에서 유저 정보 뽑기?
                    
                    //임시로 무조건 로그인하도록 하기
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
                
                self.signUpFirebase(token)
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
//                guard let accessToken = token.accessToken else { return }
                
                self.signUpFirebase(token)
            }
        }
    }
    
    func signUpFirebase(_ token: OAuthToken) {
        //파이어베이스 인증 서버에 회원가입 및 로그인을 완료합니다.
        //로그인 여부를 확인합니다.
        
        UserApi.shared.me { user, error in
            if let error = error {
                print("사용자 정보 가져오기 에러: \(error.localizedDescription)")
            } else {
                print("사용자 정보 가져오기 성공")
                
                guard let user = user else { return }
                guard let kakaoUser = user.kakaoAccount else {
                    print("Can't get kakaoAccount from user")
                    return
                }
                
                let nickName = kakaoUser.profile?.nickname ?? "카카오"
                
                //유저가 이메일을 넘겨주지 않는 경우: 임의로 이메일 만들어주기?
                //해결: 비즈 앱으로 만들어서 이메일 필수로 받아옴
                
                guard let email = kakaoUser.email else {
                    print("Can't get email from user data")
                    return
                }
                
                let password = "\(String(describing: user.id))"
                print("email: \(email) and password: \(password)")
                
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    //에러 메시지 따라 분기 처리하기
                    if let error = error {
                        let message = self.handleErrorCodes(error: error as NSError)
                        if message == "이미 사용 중인 이메일입니다." {
                            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                                if let error = error {
                                    print("Error with sign in firebase: \(error.localizedDescription)")
                                    return
                                }
                                self.startApp()
                                return
                            }
                        } else {
                            print("Error with creating user in firebase: \(error.localizedDescription)")
                            return
                        }
                    }
                    
                    guard let result = result else { return }
                    
                    //get email from token
                    guard let email = result.user.email else { return }
                    //uid
                    let uid = result.user.uid
                    
                    self.dataManager.queryDuplicateUserData(uid: uid, email: email, nickName: nickName) { result in
                        switch result {
                        case true:
                            let alert = UIAlertController(title: "성공", message: "유저 등록에 성공했습니다.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default) { action in
                                //start the app
                                self.startApp()
                            }
                            alert.addAction(action)
                            
                            DispatchQueue.main.async {
                                self.present(alert, animated: true)
                            }
                        case false:
                            let alert = UIAlertController(title: "실패", message: "유저 등록에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default)
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
    
    
    @objc func handleShowLogIn() {
        _ = navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - ASAuthorizationControllerDelegate

extension SignUpVC: ASAuthorizationControllerDelegate {
    
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
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print ("Error Apple sign in: %@", error.localizedDescription)
                    return
                }
                
                // User is signed in to Firebase with Apple.
                
                guard let result = result else { return }
                
                //get email from token
                guard let email = result.user.email else { return }
                //uid
                let uid = result.user.uid
                let nickName = "애플"
                
                self.dataManager.queryDuplicateUserData(uid: uid, email: email, nickName: nickName) { result in
                    switch result {
                    case true:
                        let alert = UIAlertController(title: "성공", message: "유저 등록에 성공했습니다.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default) { action in
                            //start the app
                            self.startApp()
                        }
                        alert.addAction(action)
                        
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    case false:
                        let alert = UIAlertController(title: "실패", message: "유저 등록에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default)
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

//MARK: - ASAuthorizationControllerPresentationContextProviding

extension SignUpVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

//MARK: - TextFieldDelegate

extension SignUpVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
