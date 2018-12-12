//
//  Extensions.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 21/11/2018.
//  Copyright © 2018 Brian MacPherson. All rights reserved.
//

import UIKit


extension UIColor {
    static func netRoadshowGray(a: CGFloat) -> UIColor {
        return UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: a)
    }
    static func netRoadshowDarkGray(a: CGFloat) -> UIColor {
        return UIColor(red: 118/255, green: 118/255, blue: 118/255, alpha: a)
    }
    static func netRoadshowBlue(a: CGFloat) -> UIColor {
        return UIColor(red: 40/255, green: 82/255, blue: 152/255, alpha: a)
    }

}

extension UIView {
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.3
    }
    
}

extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}

extension UserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)
    }
    
}

extension NSMutableAttributedString {
    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            if let f = value as? UIFont, let newFontDescriptor = f.fontDescriptor.withFamily(font.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(.foregroundColor, range: range)
                    addAttribute(.foregroundColor, value: color, range: range)
                }
            }
        }
        endEditing()
    }
}

extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension HomeController: UITextViewDelegate {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.startButtonBottomConstraint.constant = -self.keyboardHeight - 8
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        if textBox.textColor == .lightGray {
            textBox.text = nil
            textBox.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.startButtonBottomConstraint.constant = -8
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        if textBox.text.isEmpty {
            textBox.text = "Type or paste your script here..."
            textBox.textColor = .lightGray
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
            //content offset unneeded
        } else {
            if scrollView.contentOffset.x != 0 {
                scrollView.contentOffset.x = 0
            }
        }
    }
}

extension RollingTextController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return markerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return markerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard !markerArray.isEmpty else {return}
        let marker = "##\(row + 1)"
        if let range = textInput.range(of: marker) {
            let nsRange = textInput.nsRange(from: range)
            textView.scrollRangeToVisible(nsRange)
        }
        controlBar.markerInput.text = "Skip to \(markerArray[row])"
        controlBar.markerInput.resignFirstResponder()
    }
    
}

