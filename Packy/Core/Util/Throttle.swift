//
//  Throttle.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

/// Reference Source - https://github.com/boraseoksoon/Throttler

/// 특정 작업의 실행 빈도를 제한하여 지정된 기간보다 빈번하게 호출되지 않도록 하는 함수입니다.
///
/// - Parameters:
///   - duration: 스로틀을 적용할 기준 시간. 예) `.seconds(2.0)` / 기본값은 1초
///   - identifier: 서로 다른 스로틀 작업을 구분하는 식별자입니다. 동일한 id값을 사용하면, 하나의 throttle 작업으로 그룹화됩니다.
///   - actorType: 작업이 실행되어야 하는 액터 타입 (기본값은 `.main`)
///   - operation: 스로틀될 때 실행될 작업
///
/// - Note: 이 메서드는 지정된 액터 컨텍스트 내에서 Thread-Safe 방식으로 작업이 실행되도록 보장합니다. `identifier`를 제공하는 것이 명확성을 위해 권장되며, 긴 콜 스택 심볼로 인한 잠재적 문제를 피할 수 있습니다. (내부 스택 추적을 사용하는 것은 위험을 수반합니다.)
func throttle(
    _ duration: Duration = .seconds(1.0),
    identifier: String = "\(Thread.callStackSymbols)",
    byActor actorType: ActorType = .mainActor,
    operation: @escaping () -> Void
) {
    Task {
        await throttler.throttle(
            duration,
            identifier: identifier,
            byActor: actorType,
            operation: operation
        )
    }
}


/// 작업 실행에 사용될 액터 타입을 정의하는 열거형.
enum ActorType {
    case currentActor  // 현재 액터
    case mainActor     // 메인 액터

    /// 주어진 작업을 비동기적으로 실행하는 함수.
    @Sendable
    fileprivate func run(_ operation: () -> Void) async {
        self == .mainActor ? await MainActor.run { operation() } : operation()
    }
}

// MARK: - Private

private let throttler = Throttler()

/// 스로틀 작업을 관리하는 액터
private actor Throttler {
    private lazy var lastAttemptDateById: [String: Date] = [:] // ID 값에 따른 마지막 시도 시간을 저장하는 딕셔너리.

    /// 주어진 작업을 스로틀함
    func throttle(
        _ duration: Duration = .seconds(1.0),
        identifier: String = "\(Thread.callStackSymbols)",
        byActor actorType: ActorType = .mainActor,
        operation: @escaping () -> Void
    ) async {
        let now = Date()
        // 마지막 작업 시도 시간을 가져옴 (없으면 가장 과거로 설정)
        let lastDate = lastAttemptDateById[identifier] ?? .distantPast

        // 마지막 작업 시도로부터 경과한 시간을 계산
        let timeIntervalSinceLastAttempt = now.timeIntervalSince(lastDate)

        let isTimeElapsed = timeIntervalSinceLastAttempt > duration.timeInterval
        let isFirstAttempt = lastDate == .distantPast

        // 지정된 기간이 경과했거나 첫 번째 시도인 경우에만 작업 실행
        guard isTimeElapsed || isFirstAttempt else { return }

        lastAttemptDateById[identifier] = now
        await actorType.run(operation)
    }
}

private extension Duration {
    var timeInterval: TimeInterval {
        TimeInterval(components.seconds) + Double(components.attoseconds)/1e18
    }
}
