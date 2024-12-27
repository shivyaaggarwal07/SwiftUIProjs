//
//  Contact.swift
//  SwiftUICoordinator
//
//  Created by Shiaggar on 27/12/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model

class Contact: Identifiable {
    
    @Attribute(.unique) var id = UUID()
    var name: String
    var phone: String
    var email: String
    var isFavorite: Bool = false
    
    init(name: String, phone: String, email: String, isFavorite: Bool = false) {
        self.name = name
        self.phone = phone
        self.email = email
        self.isFavorite = isFavorite
    }
}
