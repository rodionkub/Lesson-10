//
//  Post+CoreDataProperties.swift
//  FinalTask
//
//  Created by Родион Кубышкин on 30/12/2019.
//  Copyright © 2019 Родион Кубышкин. All rights reserved.
//
//

import Foundation
import CoreData


extension StoredPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredPost> {
        return NSFetchRequest<StoredPost>(entityName: "StoredPost")
    }

    @NSManaged public var date: String?
    @NSManaged public var text: String?
    @NSManaged public var image: Data?
    @NSManaged public var likes: Int16
    @NSManaged public var comments: Int16

}
