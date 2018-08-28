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

class ChartProgramsStoreViewController: UIViewController, SelectedChartProgramsDataSource {

    @IBOutlet weak var chartProgramsTableView: UITableView!
    @IBOutlet weak var chartProgramsSegmentedControl: UISegmentedControl!
    
    // MARK: - Properties

    private var dataSource: ChartProgramStoreDataSource

    var loadingView: LoadingView?
    var shouldHideLoadingView = false
    var programForSegue: StoreProgram?
    var catrobatProject: StoreProgram?
    var loadingViewFlag = false

    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        self.dataSource = ChartProgramStoreDataSource.dataSource()
        super.init(coder: aDecoder)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initSegmentedControl()
        setupTableView()
        shouldHideLoadingView = false
        dataSource.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingViewHandlerAfterFetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueToProgramDetail {
            if let programDetailStoreViewController = segue.destination as? ProgramDetailStoreViewController,
                let catrobatProject = programForSegue {
                programDetailStoreViewController.project = catrobatProject
            }
        }
    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            fetchData(type: .mostDownloaded)
        case 1:
            fetchData(type: .mostViewed)
        case 2:
            fetchData(type: .mostRecent)
        default:
            break
        }
    }
    
    // MARK: - Helper Methods
    
    func initSegmentedControl() {
        chartProgramsSegmentedControl?.setTitle(kLocalizedMostDownloaded, forSegmentAt: 0)
        chartProgramsSegmentedControl?.setTitle(kLocalizedMostViewed, forSegmentAt: 1)
        chartProgramsSegmentedControl?.setTitle(kLocalizedNewest, forSegmentAt: 2)
        fetchData(type: .mostDownloaded)
        
        if(checkIphoneScreenSize()) {
            let font = UIFont.systemFont(ofSize: 10)
            chartProgramsSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        }
    }
    
    // check iPhone4 or iphone5
    private func checkIphoneScreenSize() -> Bool {
        let screenHeight = Float(Util.screenHeight())
        return (((screenHeight - kIphone4ScreenHeight) == 0) || ((screenHeight - kIphone5ScreenHeight) == 0)) ? true : false
    }
    
    private func setupTableView() {
        self.chartProgramsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.chartProgramsTableView.backgroundColor = UIColor.background()
        self.chartProgramsTableView.separatorColor = UIColor.globalTint()
        self.chartProgramsTableView.dataSource = self.dataSource
        self.chartProgramsTableView.delegate = self.dataSource
    }
    
    private func fetchData(type: ProgramType) {
        self.showLoadingView()
        self.dataSource.fetchItems(type: type) { error in
            if error != nil {
                self.shouldHideLoadingView = true
                self.hideLoadingView()
                self.showConnectionIssueAlertAndDismiss(error: error!)
                self.chartProgramsTableView.separatorStyle = .singleLine
                return
            }
            self.chartProgramsTableView.reloadData()
            self.shouldHideLoadingView = true
            self.hideLoadingView()
            self.chartProgramsTableView.separatorStyle = .singleLine
        }
    }
    
    private func showConnectionIssueAlertAndDismiss(error: StoreProgramDownloaderError) {
        var title = ""
        var message = ""
        let buttonTitle = kLocalizedOK
        
        switch error {
        case .timeout:
            title = kLocalizedServerTimeoutIssueTitle
            message = kLocalizedServerTimeoutIssueMessage
        default:
            title = kLocalizedChartProgramsLoadFailureTitle
            message = kLocalizeChartProgramsLoadFailureMessage
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(title: buttonTitle, style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadingViewHandlerAfterFetchData() {
        if loadingViewFlag == false {
            self.showLoadingView()
            self.shouldHideLoadingView = true
            self.hideLoadingView()
        }
        else {
            self.shouldHideLoadingView = true
            self.hideLoadingView()
            loadingViewFlag = false
        }
    }
    
    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
        }
        loadingView!.show()
        loadingIndicator(true)
    }
    
    func hideLoadingView() {
        if shouldHideLoadingView {
            loadingView!.hide()
            loadingIndicator(false)
            self.shouldHideLoadingView = false
        }
    }
    
    func loadingIndicator(_ value: Bool) {
        let app = UIApplication.shared
        app.isNetworkActivityIndicatorVisible = value
    }
}

extension ChartProgramsStoreViewController: ChartProgramCellProtocol{
    func selectedCell(dataSource datasource: ChartProgramStoreDataSource, didSelectCellWith cell: ChartProgramCell) {
        if let program = cell.program {
            self.showLoadingView()
            loadingViewFlag = true
            programForSegue = program
            performSegue(withIdentifier: kSegueToProgramDetail, sender: self)
        }
    }
}

extension ChartProgramsStoreViewController {
    func scrollViewHandler(dataSource: ChartProgramStoreDataSource) {
        chartProgramsTableView.reloadData()
    }
}
