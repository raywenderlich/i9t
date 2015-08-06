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

class AddDiaryEntryViewController: UITableViewController {
  
  @IBOutlet var diaryEntryTextView: UITextView!
  
  lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
  
  var diaryEntry: DiaryEntry? {
    if let entryText = diaryEntryTextView.text {
      let date = dateFormatter.stringFromDate(NSDate())
      return DiaryEntry(date: date, text: entryText)
    } else {
      return nil
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    diaryEntryTextView.becomeFirstResponder()
    
    tableView.backgroundColor = UIColor(white: 246/255, alpha: 1.0)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    diaryEntryTextView.resignFirstResponder()
  }
  
  // MARK: - UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 {
      diaryEntryTextView.becomeFirstResponder()
    }
  }
  
  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    if let headerView = view as? UITableViewHeaderFooterView {
      headerView.textLabel?.font = UIFont.systemFontOfSize(16.0)
      headerView.textLabel?.textColor = UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0)
    }
  }
}

