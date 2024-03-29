//
// Device.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct Device: Codable, JSONEncodable, Hashable {
    /** Date/time of creation */
    public var createdAt: Date
    /** Whether device is disabled or not */
    public var disabled: Bool?
    /** Reason explaining why device had been disabled */
    public var disabledReason: String?
    public var id: String
    public var pushProvider: String
    public var pushProviderName: String?
    /** When true the token is for Apple VoIP push notifications */
    public var voip: Bool?

    public init(createdAt: Date, disabled: Bool? = nil, disabledReason: String? = nil, id: String, pushProvider: String, pushProviderName: String? = nil, voip: Bool? = nil) {
        self.createdAt = createdAt
        self.disabled = disabled
        self.disabledReason = disabledReason
        self.id = id
        self.pushProvider = pushProvider
        self.pushProviderName = pushProviderName
        self.voip = voip
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case createdAt = "created_at"
        case disabled
        case disabledReason = "disabled_reason"
        case id
        case pushProvider = "push_provider"
        case pushProviderName = "push_provider_name"
        case voip
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(disabled, forKey: .disabled)
        try container.encodeIfPresent(disabledReason, forKey: .disabledReason)
        try container.encode(id, forKey: .id)
        try container.encode(pushProvider, forKey: .pushProvider)
        try container.encodeIfPresent(pushProviderName, forKey: .pushProviderName)
        try container.encodeIfPresent(voip, forKey: .voip)
    }
}

