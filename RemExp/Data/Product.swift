//
//  Product.swift
//  RemExp
//
//  Created by Heedon on 2023/05/22.
//

import UIKit

//구분: barcode

struct Product: Codable {
    var barcode: String
    var brandName: String
    var productName: String
    var category: String
    var imageUrl: String
}
