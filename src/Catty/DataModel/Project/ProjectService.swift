/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

import Foundation

@objc open class ProjectService: NSObject {

    @objc static func getProjectDirectoryName(projectName: String, projectID: String?) -> String {
        return String.init(format: "%@%@%@", projectName, kProjectIDSeparator, projectID ?? kNoProjectIDYetPlaceholder)
    }

    @objc static func getProjectLoadingInfo(directoryName: String) -> ProjectLoadingInfo? {
        //TODO: CBAssert(directoryName)
        let directoryNameParts = directoryName.components(separatedBy: kProjectIDSeparator)

        if directoryNameParts.count < 2 {
            return nil
        }
        let projectID = directoryNameParts.last!

        let projectName = String(directoryName.prefix(directoryName.count - projectID.count - 1))

        return ProjectLoadingInfo.init(forProjectWithName: projectName, projectID: projectID)
    }

    @objc static func getProjectPath(projectName: String, projectID: String?) -> String {
        return String.init(format: "%@%@/", Project.basePath(), getProjectDirectoryName(projectName: Util.replaceBlockedCharacters(for: projectName), projectID: projectID))
    }

    @objc static func setAsLastUsedProject(project: Project)
    {
        Util.setLastProjectWithName(project.header.programName, projectID: project.header.programID)
    }

    @objc static func getAllProjectLoadingInfos() -> [ProjectLoadingInfo]
    {
        let basePath = Project.basePath()
        let subdirNames: [String]

        do {
           subdirNames = try FileManager.default.contentsOfDirectory(atPath: basePath)
        } catch {
            return [ProjectLoadingInfo]()
        }

        subdirNames.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

        var projectLoadingInfos = [ProjectLoadingInfo]()

        for subdirName in subdirNames {
            // exclude .DS_Store folder on MACOSX simulator
            if subdirName.elementsEqual(".DS_Store") {
                continue
            }

            if let info = getProjectLoadingInfo(directoryName: subdirName) {
                debugPrint("Adding loaded project: \(info.basePath ?? "no_base_path_found")")
                projectLoadingInfos.append(info)
            } else {
                debugPrint("Unable to load project located in directory \(subdirName)")
                continue
            }
        }
        return projectLoadingInfos;
    }
//
//
//
//
//
//
//
//
//
//
//
//
//    static func removeProjectFromDiskWithProjectName(projectName: String, projectId: String) {
//        let fileManager = CBFileManager.shared()
//        let projectPath = self.projectPathForProjectWithName(projectName: projectName, projectID: projectId)
//
//        if ((fileManager?.directoryExists(projectPath))!) {
//            fileManager?.deleteDirectory(projectPath)
//        }
//
//        // if this is currently set as last used project, then look for next project to set it as
//        // the last used project
//        if (Project.isLastUsedProject(projectName, projectID: projectId)) {
//            Util.setLastProjectWithName(nil, projectID: nil)
//            let allProjectLoadingInfos = Project.allProjectLoadingInfos()
//            for projectLoadingInfo in allProjectLoadingInfos {
//                Util.setLastProjectWithName(projectLoadingInfo, projectID: <#T##String!#>)
//                break;
//            }
//        }
//
//
//
//
//
//        // if this is currently set as last used project, then look for next project to set it as
//        // the last used project
//        if ([Project isLastUsedProject:projectName projectID:projectID]) {
//            [Util setLastProjectWithName:nil projectID:nil];
//            NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
//            for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
//                [Util setLastProjectWithName:projectLoadingInfo.visibleName projectID:projectLoadingInfo.projectID];
//                break;
//            }
//        }
//
//        // if there are no projects left, then automatically recreate default project
//        [fileManager addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist];
//    }
//
//
//
}







