/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import TravelogKit

class LogCell: UITableViewCell {
  
  @IBOutlet private var customTextLabel: UILabel!
  @IBOutlet private var customImageView: UIImageView!
  
  func setLog(log: BaseLog?) {
    // If it's a textLog, update label and hide image view.
    // If it's an image log, update image view and hide label.
    // If it's neither of them, hide both label and image view.
    if let log = log as? TextLog {
      customTextLabel.hidden = false
      customImageView.hidden = true
      customTextLabel.text = log.text
      customImageView.image = nil
    } else if let log = log as? ImageLog {
      customTextLabel.hidden = true
      customImageView.hidden = false
      customTextLabel.text = nil
      customImageView.image = log.image
    } else {
      customTextLabel.hidden = true
      customImageView.hidden = true
      customTextLabel.text = nil
      customImageView.image = nil
    }
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // A block of animation code to run when cell is selected.
    let animationBlockSelected: (() -> Void) = {
      self.contentView.alpha = 0.5
      self.backgroundColor = UIColor.ultimateRedColor().colorWithAlphaComponent(0.3)
    }
    
    // A block of animation code to run when cell is unselected.
    let animationBlockUnselected: (() -> Void) = {
      self.contentView.alpha = 1.0
      self.backgroundColor = UIColor.whiteColor()
    }
    
    let animationBlock = (selected) ? animationBlockSelected : animationBlockUnselected
    UIView.animateWithDuration(0.25, animations: animationBlock)
  }
}