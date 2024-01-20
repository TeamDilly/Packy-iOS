//
//  AlertButtonTint.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import SwiftUI

extension View {
    func alertButtonTint(color: Color) -> some View {
        modifier(AlertButtonTintColor(color: color))
    }
}

struct AlertButtonTintColor: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .onAppear {
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(color)
            }
    }
}



// let text: String = "먹어봤던 맥주 리뷰 1개만 남기면 모든 리뷰를 보실 수 있어요!"
// let attributeString = NSMutableAttributedString(string: text) // 텍스트 일부분 색상, 폰트 변경 - https://icksw.tistory.com/152
// let font = UIFont(name: "NotoSansKR-Medium", size: 16)
// attributeString.addAttribute(.font, value: font!, range: (text as NSString).range(of: "\(text)")) // 폰트 적용.
// attributeString.addAttribute(.foregroundColor, value: UIColor.mainYellow, range: (text as NSString).range(of: "먹어봤던 맥주 리뷰 1개")) // '먹어봤던 맥주 리뷰 1개' 부분 색상 옐로우 변경.
// attributeString.addAttribute(.foregroundColor, value: UIColor.mainWhite, range: (text as NSString).range(of: "만 남기면 모든 리뷰를 보실 수 있어요!")) // 나머지 부분 색상 화이트 변경.
// 
// let alertController = UIAlertController(title: text, message: "", preferredStyle: UIAlertController.Style.alert)
// alertController.setValue(attributeString, forKey: "attributedTitle") // 폰트 및 색상 적용.
// 
// let reviewWrite = UIAlertAction(title: "리뷰쓰기", style: .cancel, handler: {
//     action in
//     print("리뷰쓰기 버튼 클릭함.")
// })
// let cancle = UIAlertAction(title: "나중에하기", style: .default, handler: nil)
// 
// reviewWrite.setValue(UIColor.mainYellow, forKey: "titleTextColor") // 색상 적용.
// cancle.setValue(UIColor.mainWhite, forKey: "titleTextColor") // 색상 적용.
// 
// alertController.addAction(reviewWrite)
// alertController.addAction(cancle)
// 
// // 배경색 변경
// alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .subBlack3
// 
// present(alertController, animated: true, completion: nil)
