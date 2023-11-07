//
//  AppDelegate.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore

import FirebaseMessaging
import UserNotifications

import GoogleSignIn
import KakaoSDKCommon

import AdSupport
import AppTrackingTransparency
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
//        Messaging.messaging().delegate = self
//        //UNUserNotificationCenter는 푸시 알림을 포함하여 앱의 모든 알림 관련 활동을 처리합니다.
//        UNUserNotificationCenter.current().delegate = self
//       
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
//            guard success else { return }
//            
//            print("Success in APNS registry")
//        }
//        
//        application.registerForRemoteNotifications()
        
        
        //ad permission from user
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("status = authorized")
                    print("IDFA = \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied:
                    print("status = denied")
                case .notDetermined:
                    print("status = notDetermined")
                case .restricted:
                    print("status = restricted")
                @unknown default:
                    print("status = default")
                }
                
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
        }
        

        let db = DB_REF
        
        let kakaoNativeKey = APIKey.kakao
        KakaoSDK.initSDK(appKey: kakaoNativeKey)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    //MARK: - GIDSIgnIn
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}


//extension AppDelegate: UNUserNotificationCenterDelegate {
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//    }
//
//    //foreground 알림 보이게 하기
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.banner, .sound, .badge])
//    }
//
//}
//
//
//extension AppDelegate: MessagingDelegate {
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        // 여기서 이제 서버로 다시 fcm 토큰을 보내줘야 한다!
//        // 그러나 서버가 없기 때문에 이렇게 token을 출력하게 한다.
//        // 이 토큰은 뒤에서 Test할때 필요하다!
//        print("Get token!")
//        messaging.token { token, _ in
//            guard let token = token else { return }
//
//            print("Token: \(token)")
//        }
//    }
//
//}
