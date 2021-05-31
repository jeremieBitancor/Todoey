//
//  CategoryModel.swift
//  Todoey
//
//  Created by jeremie bitancor on 4/6/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCategoryModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String?
    let items = List<RealmItemModel>()
}
