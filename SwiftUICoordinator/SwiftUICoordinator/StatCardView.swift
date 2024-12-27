//
//  StatCardView.swift
//  SwiftUICoordinator
//
//  Created by Shiaggar on 27/12/24.
//

import SwiftUI

struct StatCardView: View {
    
    var title: String
    var value: String
    var colour: Color
    
    var body: some View {
        VStack {
            Text(value).font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(colour)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(colour)
        }
        .frame(width: 150, height: 100)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}


