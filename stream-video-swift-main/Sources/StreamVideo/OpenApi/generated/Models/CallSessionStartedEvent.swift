//
// CallSessionStartedEvent.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
/** This event is sent when a call session starts */

public struct CallSessionStartedEvent: @unchecked Sendable, Event, Codable, JSONEncodable, Hashable, WSCallEvent {
    public var call: CallResponse
    public var callCid: String
    public var createdAt: Date
    /** Call session ID */
    public var sessionId: String
    /** The type of event: \"call.session_started\" in this case */
    public var type: String = "call.session_started"

    public init(call: CallResponse, callCid: String, createdAt: Date, sessionId: String, type: String = "call.session_started") {
        self.call = call
        self.callCid = callCid
        self.createdAt = createdAt
        self.sessionId = sessionId
        self.type = type
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case call
        case callCid = "call_cid"
        case createdAt = "created_at"
        case sessionId = "session_id"
        case type
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(call, forKey: .call)
        try container.encode(callCid, forKey: .callCid)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(type, forKey: .type)
    }
}
