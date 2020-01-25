//
//  NotSelectableTextView.swift
//  Sail
//
//  Created by user on 2020/01/12.
//  Copyright © 2020 rinsuki. All rights reserved.
//

import UIKit

// thanks to https://stackoverflow.com/a/44878203
class NotSelectableTextView: UITextView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let attributedText = self.attributedText else {
            return false
        }
        guard let pos = closestPosition(to: point) else { return false }
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else {
            return false
        }
        
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}
