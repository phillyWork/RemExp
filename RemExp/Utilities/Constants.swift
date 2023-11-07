//
//  Constants.swift
//  RemExp
//
//  Created by Heedon on 2023/05/08.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

//MARK: - Assets of Color and Icons

let viewBackgroundColor = UIColor(named: "backgroundColor")
let cellColor = UIColor(named: "cellColor")
let viewTextColor = UIColor(named: "textColor")
let brandColor = UIColor(named: "brandColor")
let brandInactiveColor = UIColor(named: "brandInactiveColor")
let expirationColor1 = UIColor(named: "expirationColor1")
let expirationColor2 = UIColor(named: "expirationColor2")
let expirationColor3 = UIColor(named: "expirationColor3")
let blueButtonColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)

//chart color
let colorful1 = UIColor(named: "colorful1")
let colorful2 = UIColor(named: "colorful2")
let colorful3 = UIColor(named: "colorful3")
let colorful4 = UIColor(named: "colorful4")
let colorful5 = UIColor(named: "colorful5")

let joyful1 = UIColor(named: "joyful1")
let joyful2 = UIColor(named: "joyful2")
let joyful3 = UIColor(named: "joyful3")
let joyful4 = UIColor(named: "joyful4")
let joyful5 = UIColor(named: "joyful5")

let liberty1 = UIColor(named: "liberty1")
let liberty2 = UIColor(named: "liberty2")
let liberty3 = UIColor(named: "liberty3")
let liberty4 = UIColor(named: "liberty4")
let liberty5 = UIColor(named: "liberty5")

let pastel1 = UIColor(named: "pastel1")
let pastel2 = UIColor(named: "pastel2")
let pastel3 = UIColor(named: "pastel3")
let pastel4 = UIColor(named: "pastel4")
let pastel5 = UIColor(named: "pastel5")

let material1 = UIColor(named: "material1")
let material2 = UIColor(named: "material2")
let material3 = UIColor(named: "material3")
let material4 = UIColor(named: "material4")

let vordiplom1 = UIColor(named: "vordiplom1")
let vordiplom2 = UIColor(named: "vordiplom2")
let vordiplom3 = UIColor(named: "vordiplom3")
let vordiplom4 = UIColor(named: "vordiplom4")
let vordiplom5 = UIColor(named: "vordiplom5")

let accountSelected = UIImage(named: "account_selected")
let accountUnselected = UIImage(named: "account_unselected")
let addImage = UIImage(named: "add")
let listSelected = UIImage(named: "list_selected")
let listUnselected = UIImage(named: "list_unselected")
let notificationImage = UIImage(named: "notification")
let sortImage = UIImage(named: "sort")
let logoImage = UIImage(named: "logo")

let kakaoButtonImage = UIImage(named: "kakaoLoginButton")

//MARK: - Root References
let DB_REF = Firestore.firestore()
let STORAGE_REF = Storage.storage().reference()

//MARK: - Firestore DB References
let DB_USERS = DB_REF.collection("users")
let DB_PRODUCTS = DB_REF.collection("products")

//MARK: - Storage References

let STORAGE_PRODUCTS_REF = STORAGE_REF.child("products")



