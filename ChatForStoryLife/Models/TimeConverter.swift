//
//  TimeConverter.swift
//  ChatForStoryLife
//
//  Created by Максим Шамов on 25.04.2024.
//

import Foundation

func formatMessageTime(_ created: Int) -> String {
    let createdTimestamp: TimeInterval = TimeInterval(created)
    let createdDate = Date(timeIntervalSince1970: createdTimestamp)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let formattedTime = dateFormatter.string(from: createdDate)
    
    return formattedTime
}
