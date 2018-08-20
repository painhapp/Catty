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

protocol RecentProgramStoreDataSourceDelegate: class {
    func recentProgramsStoreTableDataSource(_ dataSource: RecentProgramStoreDataSource, didSelectCellWith item: StoreProgram)
}

protocol SelectedRecentProgramsDataSource: class {
    func selectedCell(dataSource: RecentProgramStoreDataSource, didSelectCellWith cell: RecentProgramCell)
    func scrollViewHandler(dataSource: RecentProgramStoreDataSource)
}

class RecentProgramStoreDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties

    weak var delegate: SelectedRecentProgramsDataSource?

    let downloader: StoreProgramDownloaderProtocol
    var baseUrl = ""
    var programType: ProgramType
    
    var mostDownloadedPrograms = [StoreProgram]()
    var mostViewedPrograms = [StoreProgram]()
    var mostRecentPrograms = [StoreProgram]()
    
    var mostDownloadedOffset = 0
    var mostViewedOffset = 0
    var mostRecentOffset = 0
    
    var programs: [StoreProgram] {
        switch programType {
        case .mostDownloaded:
            return mostDownloadedPrograms
        case .mostViewed:
            return mostViewedPrograms
        case .mostRecent:
            return mostRecentPrograms
        default:
            return [StoreProgram]()
        }
    }
    
    var programOffset: Int {
        switch programType {
        case .mostDownloaded:
            return mostDownloadedOffset
        case .mostViewed:
            return mostViewedOffset
        case .mostRecent:
            return mostRecentOffset
        default:
            return 0
        }
    }

    // MARK: - Initializer

    fileprivate init(with downloader: StoreProgramDownloaderProtocol) {
        self.downloader = downloader
        self.programType = .mostDownloaded
    }

    static func dataSource(with downloader: StoreProgramDownloaderProtocol = StoreProgramDownloader()) -> RecentProgramStoreDataSource {
        return RecentProgramStoreDataSource(with: downloader)
    }

    // MARK: - DataSource

    func fetchItems(type: ProgramType, completion: @escaping (StoreProgramDownloaderError?) -> Void) {
        
        programType = type
        
        if (self.programOffset == programs.count) || (programs.count == 0) {
            self.downloader.fetchPrograms(forType: type, offset: self.programOffset) {items, error in
                guard let collection = items, error == nil else { completion(error); return }
                
                switch self.programType {
                case .mostDownloaded:
                    self.mostDownloadedPrograms.append(contentsOf: collection.projects)
                    self.mostDownloadedOffset += kRecentProgramsMaxResults
                case .mostViewed:
                    self.mostViewedPrograms.append(contentsOf: collection.projects)
                    self.mostViewedOffset += kRecentProgramsMaxResults
                case .mostRecent:
                    self.mostRecentPrograms.append(contentsOf: collection.projects)
                    self.mostRecentOffset += kRecentProgramsMaxResults
                default:
                    return
                }
                self.baseUrl = collection.information.baseUrl
                completion(nil)
            }
        }
        else {
            completion(nil)
        }
    }
    
    func numberOfRows(in tableView: UITableView) -> Int {
        return self.programs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.programs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableUtil.heightForImageCell()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kImageCell, for: indexPath)
        if let cell = cell as? RecentProgramCell {
            if programs.isEmpty == false {
                let imageUrl = URL(string: self.baseUrl.appending(programs[indexPath.row].screenshotSmall!))
                let data = try? Data(contentsOf: imageUrl!)
                cell.recentImage = UIImage(data: data!)
                cell.recentTitle = programs[indexPath.row].projectName
                cell.program = programs[indexPath.row]
            }
        }
        return cell
        
    }

    // MARK: - Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: RecentProgramCell? = tableView.cellForRow(at: indexPath) as? RecentProgramCell

        self.downloader.downloadProgram(for: (cell?.program)!) { program, error in
            guard let StoreProgram = program, error == nil else { return }
            cell?.program = StoreProgram
            self.delegate?.selectedCell(dataSource: self, didSelectCellWith: cell!)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let checkPoint = Float(scrollView.contentSize.height - TableUtil.heightForImageCell())
        let currentViewBottomEdge = Float(scrollView.contentOffset.y + scrollView.frame.size.height)
        
        if currentViewBottomEdge >= checkPoint {
            self.fetchItems(type: self.programType) { _ in }
            self.delegate?.scrollViewHandler(dataSource: self)
        }
    }
}

