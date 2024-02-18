//
// ConnectedEvent.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
/** This event is sent when the WS connection is established and authenticated, this event contains the full user object as it is stored on the server */

public struct ConnectedEvent: @unchecked Sendable, Event, Codable, JSONEncodable, Hashable, WSClientEvent {
    /** The connection_id for this client */
    public var connectionId: String
    public var createdAt: Date
    public var me: OwnUserResponse
    /** The type of event: \"connection.ok\" in this case */
    public var type: String = "connection.ok"

    public init(connectionId: String, createdAt: Date, me: OwnUserResponse, type: String = "connection.ok") {
        self.connectionId = connectionId
        self.createdAt = createdAt
        self.me = me
        self.type = type
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case connectionId = "connection_id"
        case createdAt = "created_at"
        case me
        case type
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(connectionId, forKey: .connectionId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(me, forKey: .me)
        try container.encode(type, forKey: .type)
    }
}
