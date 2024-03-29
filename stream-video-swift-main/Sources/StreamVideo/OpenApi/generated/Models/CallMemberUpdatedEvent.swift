//
// CallMemberUpdatedEvent.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
/** This event is sent when one or more members are updated */

public struct CallMemberUpdatedEvent: @unchecked Sendable, Event, Codable, JSONEncodable, Hashable, WSCallEvent {
    public var call: CallResponse
    public var callCid: String
    public var createdAt: Date
    /** The list of members that were updated */
    public var members: [MemberResponse]
    /** The type of event: \"call.member_updated\" in this case */
    public var type: String = "call.member_updated"

    public init(call: CallResponse, callCid: String, createdAt: Date, members: [MemberResponse], type: String = "call.member_updated") {
        self.call = call
        self.callCid = callCid
        self.createdAt = createdAt
        self.members = members
        self.type = type
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case call
        case callCid = "call_cid"
        case createdAt = "created_at"
        case members
        case type
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(call, forKey: .call)
        try container.encode(callCid, forKey: .callCid)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(members, forKey: .members)
        try container.encode(type, forKey: .type)
    }
}

