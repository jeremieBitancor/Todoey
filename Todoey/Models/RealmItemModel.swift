//
//  ItemModel.swift
//  Todoey
//
//  Created by jeremie bitancor on 4/6/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class RealmItemModel: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: RealmCategoryModel.self, property: "items")
   
}
