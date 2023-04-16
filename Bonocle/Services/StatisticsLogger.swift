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

    // Convert to JSON
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//    let jsonData = try! encoder.encode(stats)
//    let jsonString = String(data: jsonData, encoding: .utf8)!
    
    // Log to OSLog
    let log = OSLog(subsystem: subsystem!, category: "Stats")
    os_log("Stats: %{public}@", log: log, type: .info, stats)
}
