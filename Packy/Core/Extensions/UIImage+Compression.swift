//
//  UIImage+Compression.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import UIKit

extension UIImage {
    /// 특정 용량으로 Image를 압축
    ///
    /// 1MB 로 압축하면 `Data` 의 용량은 1MB 이하로 정상적으로 압축되지만,
    /// 해당 Data를 다시 UIImage로 변환하면 용량은 기기 scale에 따라 늘어날 수 있음
    func compressTo(expectedSizeInMB: Double) async -> Data? {
        let targetSizeInBytes = Int(expectedSizeInMB * 1024 * 1024)
        let minimumCompressionQuality: Decimal = 0.0
        var compressionQuality: Decimal = 1.0

        // 이미지 변환은 무거운 작업이기에 UI block의 가능성 존재함 -> 백그라운드에서 실행
        return await withCheckedContinuation { continuation in
            while compressionQuality >= minimumCompressionQuality {
                let quality = CGFloat(NSDecimalNumber(decimal: compressionQuality).doubleValue)
                guard let data = jpegData(compressionQuality: quality) else { continue }

                if data.count < targetSizeInBytes || compressionQuality == minimumCompressionQuality {
                    continuation.resume(returning: data)
                    return
                }

                compressionQuality -= 0.1
            }
        }
    }
}
