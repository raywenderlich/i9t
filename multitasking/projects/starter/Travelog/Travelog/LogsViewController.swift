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

class LogsViewController: UITableViewController, LogStoreObserver {
  
  @IBOutlet private var photoLibraryButton: UIBarButtonItem!
  @IBOutlet private var cameraButton: UIBarButtonItem!
  @IBOutlet private var addNoteButton: UIBarButtonItem!
  
  private var logs = [BaseLog]()
  private var selectedLog: BaseLog?
  var selectedIndexPath: NSIndexPath?
  
  // MARK: View Life Cycle
  
  deinit {
    LogStore.sharedStore.unregisterObserver(self)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    splitViewController?.preferredDisplayMode = .AllVisible
    splitViewController?.delegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let hasCamera = UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) ||
      UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)
    cameraButton.enabled = hasCamera
    tableView.cellLayoutMarginsFollowReadableWidth = true
    LogStore.sharedStore.registerObserver(self)
    LogsSeed.preload()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAppearanceDidChangeWithNotification:", name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAppearanceDidChangeWithNotification:", name: UIKeyboardDidHideNotification, object: nil)
  }
  
  /// Update view and content offset when keybaord appears or disappears.
  func keyboardAppearanceDidChangeWithNotification(notification: NSNotification) {
    guard let userInfo: [NSObject: AnyObject] = notification.userInfo else { return }
    let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    let convertedFrame = view.convertRect(keyboardEndFrame, fromView: nil)
    let keyboardTop = CGRectGetMinY(convertedFrame)
    let insets = tableView.contentInset
    let tableViewContentMaxY = min(insets.top + tableView.contentSize.height, CGRectGetHeight(tableView.bounds))
    var delta = tableViewContentMaxY - keyboardTop

    // If delta is 0 or below that, it means keyboard doesn't overlap with content.
    if delta < 0.0 { delta = 0.0 }
    let offset = tableView.contentOffset
    let newOffset = CGPoint(x: offset.x, y: offset.y + delta)
    tableView.contentOffset = newOffset
  }
  
  // MARK: LogStoreObserver Protocol
  
  func logStore(store: LogStore, didUpdateLogCollection collection: LogCollection) {
    // Update our data source.
    logs = collection.sortedLogs(NSComparisonResult.OrderedAscending)
    tableView.reloadData()
  }
  
  // MARK: IBActions
  
  @IBAction func photoLibraryButtonTapped(sender: UIBarButtonItem?) {
    // Present detail view controller and forward the call.
    let vc = presentDetailViewControllerWithSelectedLog(nil)
    vc.presentCameraControllerForSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
  }
  
  @IBAction func cameraButtonTapped(sender: UIBarButtonItem?) {
    // Present detail view controller and forward the call.
    let vc = presentDetailViewControllerWithSelectedLog(nil)
    vc.presentCameraControllerForSourceType(UIImagePickerControllerSourceType.Camera)
  }
  
  @IBAction func addNoteButtonTapped(sender: UIBarButtonItem?) {
    // Present detail view controller and forward the call.
    let vc = presentDetailViewControllerWithSelectedLog(nil)
    vc.presentTextViewController(nil)
  }
  
  // MARK: Helper
  
  /// Create or reuse a Detail View Controller object.
  func detailViewController() -> DetailViewController {
    if splitViewController?.traitCollection.horizontalSizeClass == .Compact {
      let detailViewController = storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
      return detailViewController
    }
    
    let navController = splitViewController?.viewControllers.last as! UINavigationController
    let detailViewController = navController.viewControllers.first as! DetailViewController
    return detailViewController
  }
  
  /// Present DetailViewController with a given log.
  /// For convenience, returns a pointer to the controller that's just presented.
  func presentDetailViewControllerWithSelectedLog(log: BaseLog?) -> DetailViewController {
    let vc = detailViewController()
    vc.selectedLog = log
    showDetailViewController(vc, sender: nil)
    return vc
  }
  
  func deleteLog(log: BaseLog) {
    let store = LogStore.sharedStore
    store.logCollection.removeLog(log)
    store.save()
    
    if selectedLog == log && splitViewController?.traitCollection.horizontalSizeClass == .Regular {
      selectedIndexPath = nil
      let vc = detailViewController()
      vc.selectedLog = nil
    }
  }
  
  // MARK: UITableView data source and delegate
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return logs.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LogCellIdentifier", forIndexPath: indexPath) as! LogCell
    let log = logs[indexPath.row]
    cell.setLog(log)
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let newlySelectedLog = logs[indexPath.row]
    if selectedLog == newlySelectedLog {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      selectedLog = nil
      selectedIndexPath = nil
    } else {
      selectedLog = newlySelectedLog
      selectedIndexPath = indexPath
    }
    presentDetailViewControllerWithSelectedLog(selectedLog)
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.Delete
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      let log = logs[indexPath.row]
      deleteLog(log)
    }
  }
}
