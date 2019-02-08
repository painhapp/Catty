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
        return String.init(format: "%@%@/", ProjectService.basePath(), getProjectDirectoryName(projectName: Util.replaceBlockedCharacters(for: projectName), projectID: projectID))
    }

    @objc static func setAsLastUsedProject(project: Project) {
        Util.setLastProjectWithName(project.header.programName, projectID: project.header.programID)
    }

    @objc static func getAllProjectLoadingInfos() -> [ProjectLoadingInfo] {
        let basePath = ProjectService.basePath()
        var subdirNames: [String]

        do {
           subdirNames = try FileManager.default.contentsOfDirectory(atPath: basePath)
        } catch {
            return [ProjectLoadingInfo]()
        }

        subdirNames = subdirNames.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

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
        return projectLoadingInfos
    }

    @objc static func getAllProjectNames() -> [String] {
        let allProjectLoadingInfos = ProjectService.getAllProjectLoadingInfos()
        var projectNames = [String]()
        for loadingInfo in allProjectLoadingInfos {
            projectNames.append(loadingInfo.visibleName)
        }
        return projectNames
    }

    @objc static func areThereAnyProjects() -> Bool {
        return !getAllProjectNames().isEmpty
    }

    @objc static func isLastUsedProject(projectName: String, projectID: String) -> Bool {
        let lastUsedInfo = Util.lastUsedProjectLoadingInfo()
        let info = ProjectLoadingInfo.init(forProjectWithName: projectName, projectID: projectID)
        return lastUsedInfo?.isEqual(to: info) ?? false
    }

    @objc static func basePath() -> String {
        return String.init(format: "%@/%@/", Util.applicationDocumentsDirectory(), kProjectsFolder)
    }

    // returns true if either same projectID and/or same projectName already exists
    @objc static func projectExists(projectID: String) -> Bool {
        let allProjectLoadingInfos = ProjectService.getAllProjectLoadingInfos()
        for projectLoadingInfo in allProjectLoadingInfos {
            if projectID.elementsEqual(projectLoadingInfo.projectID) {
                return true
            }
        }
        return false
    }

    @objc static func getProject(loadingInfo: ProjectLoadingInfo) -> Project? {
        debugPrint("Try to load project '\(loadingInfo.visibleName ?? "No project name found")'")
        debugPrint("Path: \(loadingInfo.basePath ?? "No base path found")")
        let xmlPath = String.init(format: "%@%@", loadingInfo.basePath, kProjectCodeFileName)
        debugPrint("XML-Path: \(xmlPath)")

        var project : Project?;
        let languageVersion = Util.detectCBLanguageVersionFromXML(withPath: xmlPath)
        if Float(languageVersion) == kCatrobatInvalidVersion {
            debugPrint("Invalid catrobat language version!")
            return nil
        }
        // detect right parser for correct catrobat language version
        let catrobatParser = CBXMLParser.init(path: xmlPath)
        if !catrobatParser!.isSupportedLanguageVersion(languageVersion) {
            let parser = Parser()
            project = parser.generateObjectForProject(withPath: xmlPath)
        } else {
            project = catrobatParser?.parseAndCreateProject()
        }

        project?.header.programID = loadingInfo.projectID

        if let project = project {
            debugPrint(project.description)
            debugPrint("ProjectResolution: width/height:  \(project.header.screenWidth.floatValue) / \(project.header.screenHeight.floatValue)")
            ProjectService.updateLastModificationTimeOfProject(projectName: loadingInfo.visibleName, projectID: loadingInfo.projectID)
        }

        return project
    }

    @objc static func removeProjectFromDisk(projectName: String, projectID: String) {
        let fileManager = CBFileManager.shared()
        let projectPath = ProjectService.getProjectPath(projectName: projectName, projectID: projectID)
        if fileManager!.directoryExists(projectPath) {
            fileManager?.deleteDirectory(projectPath)
        }

        // if this is currently set as last used project, then look for next project to set it as
        // the last used project

        if ProjectService.isLastUsedProject(projectName: projectName, projectID: projectID) {
            Util.setLastProjectWithName(nil, projectID: nil)
            let allProjectLoadingInfos = ProjectService.getAllProjectLoadingInfos()
            for projectLoadingInfo in allProjectLoadingInfos {
                Util.setLastProjectWithName(projectLoadingInfo.visibleName, projectID:projectLoadingInfo.projectID)
                break;
            }
        }

        // if there are no projects left, then automatically recreate default project
        fileManager!.addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist()
    }

    @objc static func getProjectName(projectID: String) -> String? {
        if projectID.isEmpty {
            return nil
        }

        let allProjectLoadingInfos = ProjectService.getAllProjectLoadingInfos()
        for projectLoadingInfo in allProjectLoadingInfos {
            if projectLoadingInfo.projectID.elementsEqual(projectID) {
                return projectLoadingInfo.visibleName
            }
        }

        return nil
    }

    @objc static func updateLastModificationTimeOfProject(projectName: String, projectID: String) {
        let xmlPath = String.init(format: "%@%@", ProjectService.getProjectPath(projectName: projectName, projectID: projectID), kProjectCodeFileName)
        let fileManager = CBFileManager.shared()
        fileManager?.changeModificationDate(Date.init(), forFileAtPath: xmlPath)
    }

    @objc static func projectExists(projectName: String, projectID: String) -> Bool {
        let allProjectLoadingInfos = ProjectService.getAllProjectLoadingInfos()

        // check if project with same ID already exists
        if !projectID.isEmpty {
            if ProjectService.projectExists(projectID: projectID) {
                return true
            }
        }

        // no projectID match => check if project with same name already exists
        for projectLoadingInfo in allProjectLoadingInfos {
            if projectName.elementsEqual(projectLoadingInfo.visibleName) {
                return true
            }
        }

        return false
    }
    
    @objc static func copyProject(sourceProjectName: String, sourceProjectID: String, destinationProjectName: String) {
        let sourceProjectPath = ProjectService.getProjectPath(projectName: sourceProjectName, projectID: sourceProjectID)
        destinationProjectName = Util.uniqueName(destinationProjectName, existingNames: ProjectService.getAllProjectNames())
        
       
        let destinationProjectPath = ProjectService.getProjectPath(projectName: destinationProjectName, projectID: nil)
    
        let fileManager = CBFileManager.shared()
        fileManager?.copyExistingDirectory(atPath: sourceProjectPath, toPath: destinationProjectPath)
        let destinationProjectLoadingInfo = ProjectLoadingInfo(forProjectWithName: destinationProjectName, projectID: nil)
        let project = ProjectService.getProject(loadingInfo: destinationProjectLoadingInfo!)
        project!.header.programName = destinationProjectLoadingInfo!.visibleName
        project!.saveToDisk(withNotification: true)
    }
    
    @objc static func defaultProjectWithName(projectName: String, projectID: String) -> Project {
        projectName = Util.uniqueName(projectName, existingNames: ProjectService.getAllProjectNames())
        let project = Project()
        project.header = Header.default()
        project.header.programName = projectName
        project.header.programID = projectID

        let fileManager = CBFileManager.shared()
        if !fileManager!.directoryExists(projectName) {
            fileManager?.createDirectory(project.projectPath())
        }

        let imagesDirName = String.init(format: "%@%@", project.projectPath(), kProjectImagesDirName)
        if !fileManager!.directoryExists(imagesDirName) {
            fileManager?.createDirectory(imagesDirName)
        }

        let soundsDirName = String.init(format: "%@%@", project.projectPath(), kProjectSoundsDirName)
        if !fileManager!.directoryExists(soundsDirName) {
            fileManager?.createDirectory(soundsDirName)
        }

        project.addObject(withName: kLocalizedBackground)
        debugPrint(project.description)
        return project
    }

}
