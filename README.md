# RemExp

![imagesForApp](./readMeImage/appImage.jpg)

#### 바코드 인식을 활용해 쉽게 식료품 유통기한을 등록하고 확인할 수 있는 앱입니다.

# Link

[부탁해 유통기한 앱스토어 링크](https://apps.apple.com/app/부탁해-유통기한/id6450455777)

# 개발 기간 및 인원
- 2023.05.08 ~ 2023.06.21
- 배포 이후 지속적 업데이트 중 (현재 version 1.3.1)
- 최소 버전: iOS 15.0
- 2인 개발
  - 담당 업무: iOS 개발, 앱 테마 컬러 및 디자인 개괄
  - 공통 업무: 기획 및 DB Table 설계 

# 사용 기술
- **UIKit, AVFoundation, AuthenticationServices, CryptoKit, SafariServices, AdSupport, AppTrackingTransparency, SPM**
- **FirebaseAuth, FirebaseFireStore, FirebaseStorage, GoogleSignIn, KakaoSDKAuth, KakaoSDKUser, GoogleMobileAds, Charts**
- **MVC, Singleton, GCD**
- **NSAnchor Extension, leading & trailingSwipeActionConfiguration, custom Delegate, AVCaptureVideoPreviewLayer & AVCaptureMetadataObject**

------

# 기능 구현
- `AVCaptureVideoPreviewLayer`를 활용하여 실시간 카메라 화면을 구현, `AVCaptureMetadataObject`로  바코드를 인식하는 기능 구현
  - `AVCaptureSession`에서 barcodeReader 설정
  - `AVCaptureMetadataOutputObjectsDelegate`의 `metadataOutput` 메서드에서 해당 metadata 인식 가능하면 FireStore query로 상품 등록 여부 확인
- `FireStore` 활용, 상품 정보 DB Table 설계, CRUD 구성 및 각 유저가 등록한 제품의 유통기한 정보 관리
- `FirebaseAuth`를 비롯, `GoogleSignIn`, `KakaoSDKAuth`, `AuthenticationServices`를 활용해 구글, 카카오, Sign In Apple 소셜 로그인 구현 
- tableView의 `swipeActionConfiguration`을 구현하여 등록 아이템 삭제, 사용 완료 처리 및 쿠팡 재주문 등의 기능 함축
- custom `Delegate`를 활용하여 바코드 인식 후의 상품 데이터 전달, 유저 로그아웃 및 탈퇴 시 화면전환 구현
- `AppTrackingTrasnparency` 및 `AdSupport` 통한 유저 데이터 추적 권한 요청 및 `Admob` 활용 네이티브 광고 게재

------

# Trouble Shooting

### A. 소셜 로그인 구현

#### 1. Firebase에서 제공하지 않는 카카오 계정 관리 기능

Firebase에서 Apple과 Google 계정은 각각 Sign In Apple과 Sign in with Google 기능만 구현해서 유저 확인을 해주면 등록 및 관리 작업은 알아서 해준다.
하지만 카카오 계정은 해당 기능을 제공하지 않아서 단계별로 접근해서 카카오 유저 이메일을 직접 Firebase에 등록하는 작업까지 구현을 해야 했다.

_카카오 통한 유저 계정 확인 작업_


계정 확인이 되었다면 내부적으로 직접 FireStore에 해당 이메일과 비밀번호를 등록해서 자동 로그인이 되도록 구성하기 위해 카카오에게서 유저 이메일을 받아왔어야 했다.





#### 2. Sign In Apple 구현 시 필요한 난수화

Sign In Apple은 JWT 기반으로 동작하기에 



-----

### B. DB Table 및 CRUD 설계



-----

### C. swipeAction 통한 다양한 액션 지원

처음 기획에서는 버튼을 더 제공해서 각각 기능을 부여하려 했지만 부족한 공간에 많은 버튼이 위치하면서 버튼 가독성과 활용성이 떨어지는 피드백을 받을 수 있었다. 
기획을 수정하여 등록된 제품 아이템들이 나타나는 tableView의 custom leading & trailing swipe action을 구현해서 여러 액션을 같이 제공하면 화면 구성과 더불어 사용성도 높일 수 있었다.





-----

# 회고

- 비밀번호 및 난수화에 대한 깊은 이해가 없이 구현을 시도해서 보안 요소에 대한 고려 사항을 많이 신경쓰지 못해 아쉬움이 남는다. 

- 매일 자정 혹은 유저가 정한 시간마다 FireStore에서 등록해놓은 item과 남은 날짜 계산을 통해 FCM으로 유저 Notification을 구현하려 했지만 모든 유저가 등록한 아이템 대비 FireStore Read 건수가 금방 소모될 것 같아 구현하지 못한 아쉬움이 있다. 광고 수익이 잘 나오는 서비스였다면 자체 서버 혹은 FireStore 유료 구간을 결제해서 기능 구현을 시도했을 것이다.  

- viewWillAppear에서 매번 tableView를 reload하기 보다는 아이템을 새로 등록하거나 삭제했을때만 NotificationCenter를 활용해서 `post`와 `addObserver`로 FireStore에서 read 건수를 줄일 수 있다는 생각이 든다. 이는 다음 업데이트에 시도해볼 예정이다.
