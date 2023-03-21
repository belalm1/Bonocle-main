//
//  StatisticsLogger.swift
//  Bonocle
//
//  Created by IS Student on 16/03/2023.
//

import Foundation
import WebRTC
import os

private let subsystem = Bundle.main.bundleIdentifier

func StatsToJSON(webrtc: WebRTCClient) async {
    let rtcStatsReport: RTCStatisticsReport
    await rtcStatsReport = webrtc.getConnectionStats()
    let stats = rtcStatsReport.statistics
    
    let customLog = Logger(subsystem: subsystem!, category: "WebRTC Statistics")
    //customLog.log(level: .info, "Bonocle: \(stats)")
    
//    do {
//        // Encode the array to JSON data
//        let jsonEncoder = JSONEncoder()
//        jsonEncoder.outputFormatting = .prettyPrinted
//        let jsonData = try jsonEncoder.encode(stats)
//
//        // Convert JSON data to a string
//        let jsonString = String(data: jsonData, encoding: .utf8)
//
//        // Log the JSON string
//        let customLog = Logger(subsystem: subsystem!, category: "WebRTC Statistics")
//        customLog.log(level: .info, "Bonocle: \(jsonString)")
//    } catch {
//        print("Failed to convert dictionary to JSON: \(error)")
//    }
}
