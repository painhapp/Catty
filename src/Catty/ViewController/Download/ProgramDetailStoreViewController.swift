/**
 *  Copyright (C) 2010-2018 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import TTTAttributedLabel
import UIKit
import Foundation

class ProgramDetailStoreViewController: UIViewController, ProgramStoreDelegate, UIScrollViewDelegate, FileManagerDelegate, TTTAttributedLabelDelegate, NSURLConnectionDataDelegate, DismissPopupDelegate, UIGestureRecognizerDelegate, ProgramUpdateDelegate {
    var project: CatrobatProgram?
    
    private var _projects: [AnyHashable : Any] = [:]
    var projects: [AnyHashable : Any] {
        #if false
        if !_projects {
            _projects = [AnyHashable : Any]()
        }
        #endif
        return _projects
    }
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    private var projectView: UIView?
    private var loadingView: LoadingView?
    private var loadedProgram: Program?
    
    private var _session: URLSession?
    private var session: URLSession? {
        if _session == nil {
            // Initialize Session Configuration
            let sessionConfiguration = URLSessionConfiguration.default
            
            // Configure Session Configuration
            sessionConfiguration.httpAdditionalHeaders = ["Accept": "application/json"]
            
            // Initialize Session
            _session = URLSession(configuration: sessionConfiguration)
        }
        
        return _session
    }
    private var dataTask: URLSessionDataTask?
    private var duplicateName = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Custom initialization
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        duplicateName = project?.name ?? ""
        initNavigationBar()
        hidesBottomBarWhenPushed = true
        view.backgroundColor = UIColor.background()
        print(String(format: "%@", (project?.author)!))
        loadProject(project)
        let fileManager = CBFileManager.shared()
        fileManager?.delegate = self
        fileManager?.projectURL = URL(string: project?.downloadUrl ?? "")
    }
    
    func loadProject(_ project: CatrobatProgram?) {
        projectView?.removeFromSuperview()
        projectView = createView(forProject: project)
        if self.project?.author == nil {
            showLoadingView()
            let button = projectView?.viewWithTag(Int(kDownloadButtonTag)) as? UIButton
            button?.isEnabled = false
        }
        let minHeight: CGFloat = view.frame.size.height
        if let aView = projectView {
            scrollViewOutlet.addSubview(aView)
        }
        scrollViewOutlet.delegate = self
        var contentSize: CGSize? = projectView?.bounds.size
        
        if (contentSize?.height ?? 0.0) < minHeight {
            contentSize?.height = minHeight
        }
        contentSize?.height += 30.0
        scrollViewOutlet.contentSize = contentSize ?? CGSize.zero
        automaticallyAdjustsScrollViewInsets = false
        scrollViewOutlet.isUserInteractionEnabled = true
    }
    
    func initNavigationBar() {
        navigationItem.title = kLocalizedDetails
        title = navigationItem.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidesBottomBarWhenPushed = false
        NotificationCenter.default.removeObserver(self)
    }
    
    func createView(forProject project: CatrobatProgram?) -> UIView? {
        let view: UIView? = CreateView.createProgramDetailView(project, target: self)
        if Program.programExists(withProgramID: project?.projectID) {
            view?.viewWithTag(Int(kDownloadButtonTag))?.isHidden = true
            view?.viewWithTag(Int(kPlayButtonTag))?.isHidden = false
            view?.viewWithTag(Int(kStopLoadingTag))?.isHidden = true
            view?.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = false
        } else if self.project?.isdownloading != nil {
            view?.viewWithTag(Int(kDownloadButtonTag))?.isHidden = true
            view?.viewWithTag(Int(kPlayButtonTag))?.isHidden = true
            view?.viewWithTag(Int(kStopLoadingTag))?.isHidden = false
            view?.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = true
        }
        return view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
        loadedProgram = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        self.scrollViewOutlet = nil
    }
    
    // MARK: - segue handling
    
    static let shouldPerformSegueSegueToContinue = kSegueToContinue
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == ProgramDetailStoreViewController.shouldPerformSegueSegueToContinue) {
            // The local program name with same program ID could differ from the original program name.
            // That's because the user could have renamed the downloaded program.
            let localProgramName = Program.programName(forProgramID: project?.projectID)
            
            // check if program loaded successfully -> not nil
            loadedProgram = Program(loadingInfo: ProgramLoadingInfo(forProgramWithName: localProgramName, programID: project?.projectID))
            
            if loadedProgram != nil {
                return true
            }
            // program failed loading...
            Util.alert(withText: kLocalizedUnableToLoadProgram)
            return false
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }
    
    static let prepareSegueToContinue = kSegueToContinue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == ProgramDetailStoreViewController.prepareSegueToContinue) {
            if (segue.destination is ProgramTableViewController) {
                hidesBottomBarWhenPushed = true
                let programTableViewController = segue.destination as? ProgramTableViewController
                programTableViewController?.program = loadedProgram
                programTableViewController?.delegate = self
            }
        }
    }
    
    // MARK: - program update delegates
    
    func removeProgram(withName programName: String?, programID: String?) {
        showPlayButton()
    }
    
    func renameOldProgram(withName oldProgramName: String?, programID: String?, toNewProgramName newProgramName: String?) {
        return // IMPORTANT: this method does nothing but has to be implemented!!
    }
    
    // MARK: - ProgramStore Delegate
    
    static let playButtonPressedSegueToContinue = kSegueToContinue
    
    func playButtonPressed() {
        print("Play Button")
        if shouldPerformSegue(withIdentifier: ProgramDetailStoreViewController.playButtonPressedSegueToContinue, sender: self) {
            performSegue(withIdentifier: ProgramDetailStoreViewController.playButtonPressedSegueToContinue, sender: self)
        }
    }
    
    func reportProgram() {
        print("report")
        let isLoggedIn: Bool = UserDefaults.standard.bool(forKey: kUserIsLoggedIn)
        if isLoggedIn {
            ((AlertControllerBuilder.textFieldAlert(title: kLocalizedReportProgram, message: kLocalizedEnterReason)
                .addCancelAction(withTitle: kLocalizedCancel, handler: nil)
                .addDefaultAction(withTitle: kLocalizedOK, handler: {
                    report inself.sendReport(withMessage: report)
                }).valueValidator({
                    report in
                    let minInputLength: Int = 1
                    let maxInputLength: Int = 10
                    if (report?.count ?? 0) < minInputLength {
                        return InputValidationResult.invalidInput(withLocalizedMessage: String(format: kLocalizedNoOrTooShortInputDescription, minInputLength))
                    } else if (report?.count ?? 0) > maxInputLength {
                        return InputValidationResult.invalidInput(withLocalizedMessage: String(format: kLocalizedTooLongInputDescription, maxInputLength))
                    } else {
                        return InputValidationResult.validInput()

                    }
                })).build()).show(with: self)
        } else {
            Util.alert(withText: kLocalizedLoginToReport)
        }
    }
    
    func sendReport(withMessage message: String?) {
        print(String(format: "ReportMessage::::::%@", message!))
        
        let reportUrl = Util.isProductionServerActivated() ? kReportProgramUrl : kTestReportProgramUrl
        
        var post: String? = nil
        if let anID = project?.projectID {
            post = "\("program")=\(anID)&\("note")=\(message ?? "")"
        }
        let postData: Data? = post?.data(using: .utf8, allowLossyConversion: true)
        let postLength = String(format: "%lu", UInt(postData?.count ?? 0))
        
        var request = NSMutableURLRequest()
        request.url = URL(string: "\(reportUrl)")
        request.httpMethod = "POST"
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.httpBody = postData

        dataTask = session?.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil {
                if try? Util.isNetworkError() {
                    Util.defaultAlertForNetworkError()
                    self.hideLoadingView()
                }
            } else {
                DispatchQueue.main.async(execute: {
                    var error: Error? = nil
                    var dictionary: [AnyHashable : Any]? = nil
                    if let aData = data {
                        dictionary = try? JSONSerialization.jsonObject(with: aData, options: []) as? [AnyHashable : Any]
                    }
                    var statusCode: String? = nil
                    if let aKey = dictionary?["statusCode"] {
                        statusCode = "\(aKey)"
                    }
                    
                    print(String(format: "StatusCode is %@", statusCode))
                    Util.alert(withText: dictionary?["answer"])
                })
            }
        })
        
        if dataTask != nil {
            dataTask?.resume()
            print("Connection Successful")
        } else {
            print("Connection could not be made")
        }
    }
    
    func playButtonPressed(_ sender: Any?) {
        playButtonPressed()
    }
    
    func downloadButtonPressed() {
        print("Download Button!")
        let button = projectView?.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        projectView?.viewWithTag(Int(kDownloadButtonTag))?.isHidden = true
        button?.isHidden = false
        button?.progress = 0
        download(withName: project?.name)
    }
    
    func downloadButtonPressed(_ sender: Any?) {
        downloadButtonPressed()
    }
    
    func downloadAgain() {
        let button = projectView?.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        projectView?.viewWithTag(Int(kPlayButtonTag))?.isHidden = true
        let downloadAgainButton = projectView?.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton
        downloadAgainButton?.isEnabled = false
        button?.hidden = false
        button?.progress = 0
        duplicateName = Util.uniqueName(project?.name, existingNames: Program.allProgramNames())
        print(String(format: "%@", Program.allProgramNames()))
        download(withName: duplicateName)
    }
    
    func download(withName name: String?) {
        let url = URL(string: project?.downloadUrl ?? "")
        let fileManager = CBFileManager.shared()
        fileManager?.delegate = self
        fileManager?.downloadProgram(from: url, withProgramID: project?.projectID, andName: name)
        project?.isdownloading = true
        projects[url] = project
        reloadInputViews()
    }
    
    // MARK: - File Manager Delegate
    
    func downloadFinished(with url: URL?, andProgramLoadingInfo info: ProgramLoadingInfo?) {
        print("Download Finished!!!!!!")
        project?.isdownloading = false
        projects.removeValueForKey(url)
        let button = view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        button?.hidden = true
        button?.progress = 0
        view.viewWithTag(Int(kPlayButtonTag))?.isHidden = false
        let downloadAgainButton = projectView?.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton
        downloadAgainButton?.isEnabled = true
        downloadAgainButton?.isHidden = false
        loadingIndicator(false)
    }
    
    // MARK: - TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel?, didSelectLinkWith url: URL?) {
        if let anUrl = url {
            UIApplication.shared.openURL(anUrl)
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel?, didSelectLinkWithPhoneNumber phoneNumber: String?) {
        let device = UIDevice.current
        if (device.model == "iPhone") {
            //NSString* telpromt = [phoneNumber stringByReplacingOccurrencesOfString:@"tel:" withString:@""];
            let escapedPhoneNumber = phoneNumber?.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "0123456789-+()").inverted)
            let phoneURLString = "telprompt:\(escapedPhoneNumber ?? "")"
            let url = URL(string: phoneURLString)
            if let anUrl = url {
                UIApplication.shared.openURL(anUrl)
            }
        }
    }
    
    func reload(withProject loadedProject: CatrobatProgram?) {
        loadProject(loadedProject)
        let button = projectView?.viewWithTag(Int(kDownloadButtonTag)) as? UIButton
        button?.isEnabled = true
        hideLoadingView()
        view.setNeedsDisplay()
    }
    
    // MARK: - loading view
    
    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            //        [self.loadingView setBackgroundColor:[UIColor globalTintColor]];
            if let aView = loadingView {
                view.addSubview(aView)
            }
        }
        loadingView?.show()
    }
    
    func hideLoadingView() {
        loadingView?.hide()
    }
    
    // MARK: - play button
    
    func showPlayButton() {
        projectView?.viewWithTag(Int(kDownloadButtonTag))?.isHidden = false
        projectView?.viewWithTag(Int(kStopLoadingTag))?.isHidden = true
        projectView?.viewWithTag(Int(kPlayButtonTag))?.isHidden = true
        projectView?.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = true
    }
    
    // MARK: - actions
    
    func stopLoading() {
        let url = URL(string: project?.downloadUrl ?? "")
        let fileManager = CBFileManager.shared()
        fileManager?.stopLoading(url)
        fileManager?.delegate = self
        let button = view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        button?.hidden = true
        button?.progress = 0
        let downloadAgainButton = projectView?.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton
        if downloadAgainButton?.isEnabled ?? false {
            view.viewWithTag(Int(kDownloadButtonTag))?.isHidden = false
        } else {
            view.viewWithTag(Int(kPlayButtonTag))?.isHidden = false
            downloadAgainButton?.isEnabled = true
        }
        loadingIndicator(false)
        
    }
    
    func updateProgress(_ progress: Double) {
        print(String(format: "updateProgress: %f", (Float(progress))))
        let button = view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        button?.setProgress(Float(progress), animated: true)
    }
    
    func timeoutReached() {
        setBackDownloadStatus()
        Util.defaultAlertForNetworkError()
    }
    
    func maximumFilesizeReached() {
        setBackDownloadStatus()
        Util.alert(withText: kLocalizedNotEnoughFreeMemoryDescription)
    }
    
    func fileNotFound() {
        setBackDownloadStatus()
        Util.alert(withText: kLocalizedProgramNotFound)
    }
    
    func setBackDownloadStatus() {
        view.viewWithTag(Int(kDownloadButtonTag))?.isHidden = false
        view.viewWithTag(Int(kPlayButtonTag))?.isHidden = true
        view.viewWithTag(Int(kStopLoadingTag))?.isHidden = true
        view.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = true
        loadingIndicator(false)
    }
    
    func loadingIndicator(_ value: Bool) {
        let app = UIApplication.shared
        app.isNetworkActivityIndicatorVisible = value
    }
    
    // MARK: - popup delegate
    
    func dismissPopup(withCode successLogin: Bool) -> Bool {
        if popupViewController != nil {
            dismissPopup()
            navigationItem.leftBarButtonItem?.isEnabled = true
            if successLogin {
                // TODO no trigger because popup is visible
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(0.5 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                    self.reportProgram()
                })
            }
            return true
        }
        return false
    }
    
    // MARK: Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async(execute: {
            self.loadProject(self.project)
            self.view.setNeedsDisplay()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
