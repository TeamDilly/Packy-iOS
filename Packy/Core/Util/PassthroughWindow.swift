//
//  PassthroughWindow.swift
//  Packy
//
//  Created by Mason Kim on 1/26/24.
//

import UIKit

/// 터치 이벤트를 특정 뷰에만 전달하고 나머지는 통과시키는 커스텀 UIWindow
final class PassthroughWindow: UIWindow {

    /// 주어진 점이 윈도우 내부에 있는지 확인하는 메서드
    /// iOS 18에서의 동작 변경에 대응하기 위해 오버라이드됨
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if #available(iOS 18, *) {
            return handleiOS18PointInside(point: point, with: event)
        } else {
            return super.point(inside: point, with: event)
        }
    }

    /// 터치 이벤트를 처리할 뷰를 찾는 메서드
    /// iOS 버전에 따라 다른 로직을 적용
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if #available(iOS 18, *) {
            // iOS 18 이상에서는 기본 hitTest 메서드 사용
            return super.hitTest(point, with: event)
        } else {
            // iOS 18 미만에서는 기존의 Passthrough 로직 유지
            return handleLegacyHitTest(point: point, with: event)
        }
    }
}


// MARK: - iOS 18 이상 처리 로직

@available(iOS 18, *)
private extension PassthroughWindow {
    /// iOS 18 이상에서 point(inside:with:) 처리
    /// - 참조: https://forums.developer.apple.com/forums/thread/762292
    ///
    /// iOS 18에서의 주요 변경사항 및 대응 방식:
    /// 1. `rootViewController.view`가 모든 터치 이벤트를 캡처하는 문제 발생
    /// 2. 기존 hitTest 메서드로는 깊이 정보를 얻을 수 없음
    /// 3. 해결책: 커스텀 재귀 함수로 가장 깊은 뷰를 찾아 처리
    func handleiOS18PointInside(point: CGPoint, with event: UIEvent?) -> Bool {
        guard let view = rootViewController?.view else { return false }

        // subviews가 여러 개일 경우 self를, 아니면 rootViewController의 view를 사용
        // UIAlertController 등이 표시될 때 고려한 로직
        let targetView = subviews.count > 1 ? self : view

        // 가장 깊은 hit view를 찾음
        let hitTestResult = Self.findDeepestHitTestView(point: point, with: event, in: targetView)

        // hit view가 있으면 true, 없으면 false 반환
        return hitTestResult != nil
    }

    /// 재귀적으로 뷰 계층구조를 탐색하여 가장 깊은 hit view를 찾는 메서드
    /// - 동작 방식:
    ///   1. 주어진 뷰의 모든 서브뷰를 역순으로 순회 (앞에 있는 뷰부터 처리)
    ///   2. 각 서브뷰에 대해 터치 가능 여부 확인
    ///   3. 재귀적으로 더 깊은 뷰 탐색
    ///   4. 가장 깊은 레벨의 hit view 반환
    static func findDeepestHitTestView(
        point: CGPoint,
        with event: UIEvent?,
        in view: UIView,
        depth: Int = 0
    ) -> (view: UIView, depth: Int)? {
        var deepestHit: (view: UIView, depth: Int)?

        // 뷰는 뒤에서 앞으로 순서대로 정렬되어 있음 (reversed 사용)
        for subview in view.subviews.reversed() {
            let convertedPoint = view.convert(point, to: subview)

            // 서브뷰가 터치 가능한 상태인지 확인
            guard subview.isUserInteractionEnabled,
                  !subview.isHidden,
                  subview.alpha > 0,
                  subview.point(inside: convertedPoint, with: event)
            else { continue }

            // 재귀적으로 더 깊은 서브뷰 탐색
            if let hit = findDeepestHitTestView(point: convertedPoint, with: event, in: subview, depth: depth + 1) {
                deepestHit = hit
            } else if deepestHit == nil || depth > deepestHit!.depth {
                // 현재 뷰가 더 깊거나, 아직 hit view가 없는 경우 업데이트
                deepestHit = (view: subview, depth: depth)
            }
        }

        return deepestHit
    }
}
// MARK: - iOS 18 미만 처리 로직

private extension PassthroughWindow {
    /// iOS 18 미만에서 hitTest 처리
    /// - 동작 방식:
    ///   1. 기본 hitTest 메서드 호출
    ///   2. 결과가 rootViewController의 view와 같으면 nil 반환 (이벤트 통과)
    ///   3. 그 외의 경우 hit view 반환
    func handleLegacyHitTest(point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hit ? nil : hit
    }
}
