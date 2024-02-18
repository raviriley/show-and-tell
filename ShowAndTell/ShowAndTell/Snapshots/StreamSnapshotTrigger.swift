//
//  StreamSnapshotTrigger.swift
//  ShowAndTell
//
//  Created by Ravi Riley on 2/18/24.
//

import SwiftUI
import Combine
import StreamVideo
import StreamVideoSwiftUI

final class StreamSnapshotTrigger: SnapshotTriggering {
    lazy var binding: Binding<Bool> = Binding<Bool>(
        get: { [weak self] in
            self?.currentValueSubject.value ?? false
        },
        set: { [weak self] in
            self?.currentValueSubject.send($0)
        }
    )

    var publisher: AnyPublisher<Bool, Never> { currentValueSubject.eraseToAnyPublisher() }

    private let currentValueSubject = CurrentValueSubject<Bool, Never>(false)

    init() {}

    func capture() {
        binding.wrappedValue = true
    }
}

/// Provides the default value of the `StreamSnapshotTrigger` class.
struct StreamSnapshotTriggerKey: InjectionKey {
    @MainActor
    static var currentValue: StreamSnapshotTrigger = .init()
}

extension InjectedValues {
    /// Provides access to the `StreamSnapshotTrigger` class to the views and view models.
    var snapshotTrigger: StreamSnapshotTrigger {
        get {
            Self[StreamSnapshotTriggerKey.self]
        }
        set {
            Self[StreamSnapshotTriggerKey.self] = newValue
        }
    }
}

struct SnapshotButtonView: View {
    @Injected(\.snapshotTrigger) var snapshotTrigger

    var body: some View {
        Button {
            snapshotTrigger.capture()
        } label: {
            Label {
                Text("Capture snapshot")
            } icon: {
                Image(systemName: "circle.inset.filled")
            }

        }
    }
}
