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

let kHTMLATagPattern = "(?i)<a([^>]+)>(.+?)</a>"
let kHTMLAHrefTagPattern = "href=\"(.*?)\""

class CreateView: NSObject {
    static func createProgramDetailView(_ project: CatrobatProgram?, target: Any?) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Util.screenWidth(), height: 0))
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = .flexibleHeight
        self.addNameLabel(withProjectName: project?.projectName, to: view)
        self.addAuthorLabel(withAuthor: project?.author, to: view)
        self.addThumbnailImage(withImageUrlString: project?.screenshotSmall, to: view)
        self.addDownloadButton(to: view, withTarget: target)
        self.addLoadingButton(to: view, withTarget: target)
        self.addPlayButton(to: view, withTarget: target)
        self.addDownloadAgainButton(to: view, withTarget: target)
        self.addProgramDescriptionLabel(withDescription: project?.projectDescription, to: view, target: target)

        let projectDate = Date(timeIntervalSince1970: TimeInterval(project?.uploaded ?? 0.0))
        let uploaded = CatrobatProgram.uploadDateFormatter().string(from: projectDate)

        self.addInformationLabel(to: view, withAuthor: project?.author, downloads: project?.downloads, uploaded: uploaded, version: project?.size, views: project?.views)

        self.addReportButton(to: view, withTarget: target)
        return view
    }

    static func height() -> CGFloat {
        return Util.screenHeight()
    }

    static func addNameLabel(withProjectName projectName: String?, to view: UIView?) {
        let height: CGFloat = self.height()
        let nameLabel = UILabel(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 2 - 10, y: height * 0.05, width: 155, height: 25))
        nameLabel.text = projectName
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 2
        self.configureTitleLabel(nameLabel, andHeight: height)
        nameLabel.sizeToFit()
        self.setMaxHeightIfGreaterFor(view, withHeight: nameLabel.frame.origin.y + nameLabel.frame.size.height)

        view?.addSubview(nameLabel)
    }

    static func addAuthorLabel(withAuthor author: String?, to view: UIView?) {
        let height: CGFloat = self.height()
        let authorLabel = UILabel(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 2 - 10, y: (view?.frame.size.height ?? 0.0) + 5, width: 155, height: 25))
        authorLabel.text = author
        self.configureAuthorLabel(authorLabel, andHeight: height)
        view?.addSubview(authorLabel)
        self.setMaxHeightIfGreaterFor(view, withHeight: authorLabel.frame.origin.y + authorLabel.frame.size.height)
    }

    static func addProgramDescriptionLabel(withDescription description: String?, to view: UIView?, target: Any?) -> CGFloat {
        var description = description
        let height: CGFloat = self.height()
        self.addHorizontalLine(to: view, andHeight: height * 0.35 - 15)
        let descriptionTitleLabel = UILabel(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 15, y: height * 0.35, width: 155, height: 25))
        self.configureTitleLabel(descriptionTitleLabel, andHeight: height)
        descriptionTitleLabel.text = kLocalizedDescription
        view?.addSubview(descriptionTitleLabel)

        description = description?.replacingOccurrences(of: "<br>", with: "")
        description = description?.replacingOccurrences(of: "<br />", with: "")


        if (!(description ?? "")) != "" || (description == "") {
            description = kLocalizedNoDescriptionAvailable
        }

        let maximumLabelSize = CGSize(width: 296, height: FLT_MAX)
        //    CGSize expectedSize = [description sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        var attributes: [AnyHashable : Any]
        if height == kIpadScreenHeight {
            attributes = [.font : UIFont.systemFont(ofSize: 20)]
        } else {
            attributes = [.font : UIFont.systemFont(ofSize: 14)]
        }


        let labelBounds: CGRect? = description?.boundingRect(with: maximumLabelSize, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedStringKey : Any], context: nil)
        let expectedSize = CGSize(width: ceilf(labelBounds?.size.width), height: ceilf(labelBounds?.size.height))
        //    CGSize expectedSize = [description sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];

        let descriptionLabel = TTTAttributedLabel(frame: CGRect.zero)
        if height == kIpadScreenHeight {
            descriptionLabel.frame = CGRect(x: (view?.frame.size.width ?? 0.0) / 15, y: height * 0.35 + 40, width: 540, height: expectedSize.height)
        } else {
            descriptionLabel.frame = CGRect(x: (view?.frame.size.width ?? 0.0) / 15, y: height * 0.35 + 40, width: 280, height: expectedSize.height)
        }


        self.configureDescriptionLabel(descriptionLabel)
        descriptionLabel.delegate = target
        descriptionLabel.text = description

        //    expectedSize = [descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        descriptionLabel.frame = CGRect(x: descriptionLabel.frame.origin.x, y: descriptionLabel.frame.origin.y, width: descriptionLabel.frame.size.width, height: expectedSize.height)
        view?.addSubview(descriptionLabel)
        self.setMaxHeightIfGreaterFor(view, withHeight: height * 0.35 + 40 + expectedSize.height)
        return descriptionLabel.frame.size.height
    }

    static func addThumbnailImage(withImageUrlString imageUrlString: String?, to view: UIView?) {
        let imageView = UIImageView()
        let errorImage = UIImage(named: "thumbnail_large")
        imageView.frame = CGRect(x: (view?.frame.size.width ?? 0.0) / 15, y: (view?.frame.size.height ?? 0.0) * 0.1, width: (view?.frame.size.width ?? 0.0) / 3, height: Util.screenHeight() / 4.5)
        imageView.image = UIImage(contentsOf: URL(string: imageUrlString ?? ""), placeholderImage: nil, errorImage: errorImage, onCompletion: { image in
            DispatchQueue.main.async(execute: {
                imageView.viewWithTag(Int(kActivityIndicator))?.removeFromSuperview()
                imageView.image = image
            })
        })

        if imageView.image == nil {
            let activity = UIActivityIndicatorView(style: .gray)
            activity.tag = Int(kActivityIndicator)
            activity.frame = CGRect(x: imageView.frame.size.width / 2.0 - 25.0 / 2.0, y: imageView.frame.size.height / 2.0 - 25.0 / 2.0, width: 25.0, height: 25.0)
            imageView.addSubview(activity)
            activity.startAnimating()
        }

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.utilityTint()!.cgColor
        imageView.layer.borderWidth = 1.0

        view?.addSubview(imageView)
    }

    static func addDownloadButton(to view: UIView?, withTarget target: Any?) {
        let downloadButton: UIButton? = RoundBorderedButton(frame: CGRect(x: (view?.frame.size.width ?? 0.0) - 75, y: (view?.frame.size.height ?? 0.0) * 0.1 + Util.screenHeight() / 4.5 - 25, width: 70, height: 25), andBorder: true)
        downloadButton?.tag = Int(kDownloadButtonTag)
        downloadButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        downloadButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        downloadButton?.titleLabel?.minimumScaleFactor = 0.4
        downloadButton?.setTitle(kLocalizedDownload, for: .normal)
        downloadButton?.tintColor = UIColor.buttonTint()

        downloadButton?.addTarget(target, action: #selector(CreateView.downloadButtonPressed), for: .touchUpInside)

        let activity = UIActivityIndicatorView(style: .gray)
        activity.tag = Int(kActivityIndicator)
        activity.frame = CGRect(x: 5, y: 0, width: 25, height: 25)
        downloadButton?.addSubview(activity)

        if let aButton = downloadButton {
            view?.addSubview(aButton)
        }
    }

    static func addPlayButton(to view: UIView?, withTarget target: Any?) {
        let playButton: UIButton? = RoundBorderedButton(frame: CGRect(x: (view?.frame.size.width ?? 0.0) - 75, y: (view?.frame.size.height ?? 0.0) * 0.1 + Util.screenHeight() / 4.5 - 25, width: 70, height: 25), andBorder: true)
        playButton?.tag = Int(kPlayButtonTag)
        playButton?.isHidden = true
        playButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        playButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        playButton?.titleLabel?.minimumScaleFactor = 0.4
        playButton?.setTitle(kLocalizedOpen, for: .normal)
        playButton?.addTarget(target, action: #selector(CreateView.playButtonPressed), for: .touchUpInside)
        playButton?.tintColor = UIColor.buttonTint()


        if let aButton = playButton {
            view?.addSubview(aButton)
        }
    }

    static func addDownloadAgainButton(to view: UIView?, withTarget target: Any?) {
        let downloadAgainButton = RoundBorderedButton(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 2 - 10, y: (view?.frame.size.height ?? 0.0) * 0.1 + Util.screenHeight() / 4.5 - 25, width: 100, height: 25), andBorder: false)
        downloadAgainButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        downloadAgainButton.setTitleColor(UIColor.buttonTint(), for: .normal)
        downloadAgainButton.setTitleColor(UIColor.buttonHighlightedTint(), for: .highlighted)
        downloadAgainButton.setTitle(kLocalizedDownload, for: .normal)
        downloadAgainButton.titleLabel?.adjustsFontSizeToFitWidth = true
        downloadAgainButton.titleLabel?.minimumScaleFactor = 0.4
        downloadAgainButton.addTarget(target, action: #selector(CreateView.downloadAgain), for: .touchUpInside)
        downloadAgainButton.tag = kDownloadAgainButtonTag
        downloadAgainButton.isHidden = true

        view?.addSubview(downloadAgainButton)
    }

    static func addLoadingButton(to view: UIView?, withTarget target: Any?) {
        let button = EVCircularProgressView()
        button.tag = kStopLoadingTag
        button.tintColor = UIColor.buttonTint()
        button.frame = CGRect(x: (view?.frame.size.width ?? 0.0) - 40, y: (view?.frame.size.height ?? 0.0) * 0.1 + Util.screenHeight() / 4.5 - 25, width: 28, height: 28)
        button.hidden = true
        button.addTarget(target, action: #selector(CreateView.stopLoading), for: .touchUpInside)
        view?.addSubview(button)
    }

    static func addInformationLabel(to view: UIView?, withAuthor author: String?, downloads: NSNumber?, uploaded: String?, version: String?, views: NSNumber?) {
        var version = version
        let height: CGFloat = self.height()
        var offset: CGFloat = (view?.frame.size.height ?? 0.0) + height * 0.05
        self.addHorizontalLine(to: view, andHeight: offset - 15)
        let informationLabel = UILabel(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 15, y: offset, width: 155, height: 25))
        informationLabel.text = kLocalizedInformation
        self.configureTitleLabel(informationLabel, andHeight: height)
        view?.addSubview(informationLabel)
        offset += height * 0.075

        version = version?.replacingOccurrences(of: "&lt;", with: "")
        version = version ?? "" + (" MB")

        let informationArray = ["\(views ?? "")", uploaded, version, "\(downloads ?? "")"]
        let informationTitleArray = [UIImage(named: "viewsIcon"), UIImage(named: "timeIcon"), UIImage(named: "sizeIcon"), UIImage(named: "downloadIcon")]
        let counter: Int = 0
        for info: Any in informationArray {
            let titleIcon: UIImageView? = self.getInformationTitleLabel(withTitle: informationTitleArray[counter], atXPosition: (view?.frame.size.width ?? 0.0) / 12, atYPosition: offset, andHeight: height)
            if let anIcon = titleIcon {
                view?.addSubview(anIcon)
            }

            let infoLabel: UILabel? = self.getInformationDetailLabel(withTitle: info as? String, atXPosition: (view?.frame.size.width ?? 0.0) / 12 + 25, atYPosition: offset, andHeight: height)
            if let aLabel = infoLabel {
                view?.addSubview(aLabel)
            }

            offset += +height * 0.04
            counter += 1
        }
        self.setMaxHeightIfGreaterFor(view, withHeight: offset)
    }

    static func addReportButton(to view: UIView?, withTarget target: Any?) {
        let height: CGFloat = self.height()
        self.addHorizontalLine(to: view, andHeight: (view?.frame.size.height ?? 0.0) + height * 0.01 - 15)
        let reportButton = RoundBorderedButton(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 15, y: (view?.frame.size.height ?? 0.0) + height * 0.01, width: 130, height: 25), andBorder: false)
        reportButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        reportButton.titleLabel?.tintColor = UIColor.globalTint()
        reportButton.setTitle(kLocalizedReportProgram, for: .normal)
        reportButton.addTarget(target, action: #selector(CreateView.reportProgram), for: .touchUpInside)
        reportButton.sizeToFit()
        reportButton.tintColor = UIColor.buttonTint()
        reportButton.setTitleColor(UIColor.buttonTint(), for: .normal)
        view?.addSubview(reportButton)
        self.setMaxHeightIfGreaterFor(view, withHeight: (view?.frame.size.height ?? 0.0) + reportButton.frame.size.height)
    }

    static func addHorizontalLine(to view: UIView?, andHeight height: CGFloat) {
        self.setMaxHeightIfGreaterFor(view, withHeight: height)
        let offset: CGFloat = (view?.frame.size.height ?? 0.0) + 1
        let lineView = UIView(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 15 - 10, y: offset, width: view?.frame.size.width ?? 0.0, height: 1))
        lineView.backgroundColor = UIColor.utilityTint()
        view?.addSubview(lineView)
    }

    static func addShadowToTitleLabel(for button: UIButton?) {
        button?.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        button?.titleLabel?.layer.shadowOpacity = 0.3
        button?.titleLabel?.layer.shadowRadius = 1
        button?.titleLabel?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }

    static func configureTitleLabel(_ label: UILabel?, andHeight height: CGFloat) {
        label?.backgroundColor = UIColor.clear
        if height == kIpadScreenHeight {
            label?.font = UIFont.boldSystemFont(ofSize: 24)
        } else {
            label?.font = UIFont.boldSystemFont(ofSize: 17)
        }
        label?.textColor = UIColor.globalTint()
        label?.layer.shadowColor = UIColor.white.cgColor
        label?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    static func configureTextLabel(_ label: UILabel?, andHeight height: CGFloat) {
        label?.backgroundColor = UIColor.clear
        if height == kIpadScreenHeight {
            label?.font = UIFont.boldSystemFont(ofSize: 18)
        } else {
            label?.font = UIFont.boldSystemFont(ofSize: 12)
        }
        label?.textColor = UIColor.textTint()
        label?.layer.shadowColor = UIColor.white.cgColor
        label?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    static func configureAuthorLabel(_ label: UILabel?, andHeight height: CGFloat) {
        label?.backgroundColor = UIColor.clear
        if height == kIpadScreenHeight {
            label?.font = UIFont.boldSystemFont(ofSize: 18)
        } else {
            label?.font = UIFont.boldSystemFont(ofSize: 12)
        }
        label?.textColor = UIColor.textTint()
        label?.layer.shadowColor = UIColor.white.cgColor
        label?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    static func getInformationTitleLabel(withTitle icon: UIImage?, atXPosition xPosition: CGFloat, atYPosition yPosition: CGFloat, andHeight height: CGFloat) -> UIImageView? {
        let titleInformation = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: 15, height: 15))
        titleInformation.image = icon

        return titleInformation
    }

    static func getInformationDetailLabel(withTitle title: String?, atXPosition xPosition: CGFloat, atYPosition yPosition: CGFloat, andHeight height: CGFloat) -> UILabel? {
        let detailInformationLabel = UILabel(frame: CGRect(x: xPosition, y: yPosition, width: 155, height: 25))
        detailInformationLabel.text = title?.escapingHTMLEntities()
        detailInformationLabel.textColor = UIColor.textTint()
        if height == kIpadScreenHeight {
            detailInformationLabel.font = UIFont.systemFont(ofSize: 18.0)
        } else {
            detailInformationLabel.font = UIFont.systemFont(ofSize: 14.0)
        }

        detailInformationLabel.backgroundColor = UIColor.clear
        detailInformationLabel.sizeToFit()
        return detailInformationLabel
    }

    static func setMaxHeightIfGreaterFor(_ view: UIView?, withHeight height: CGFloat) {
        var frame: CGRect? = view?.frame
        if (frame?.size.height ?? 0.0) < height {
            frame?.size.height = height
            view?.frame = frame ?? CGRect.zero
        }
    }

    static func configureDescriptionLabel(_ label: TTTAttributedLabel?) {
        let height: CGFloat = self.height()
        label?.lineBreakMode = NSLineBreakMode.byWordWrapping
        label?.numberOfLines = 0
        self.configureTextLabel(label, andHeight: height)
        label?.enabledTextCheckingTypes = NSTextCheckingAllTypes
        label?.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop

        var mutableLinkAttributes: [AnyHashable : Any] = [:]
        mutableLinkAttributes[kCTForegroundColorAttributeName as String] = UIColor.textTint()
        mutableLinkAttributes[kCTUnderlineStyleAttributeName as String] = (1)

        var mutableActiveLinkAttributes: [AnyHashable : Any] = [:]
        mutableActiveLinkAttributes[kCTForegroundColorAttributeName as String] = UIColor.brown
        mutableActiveLinkAttributes[kCTUnderlineStyleAttributeName as String] = (0)

        label?.linkAttributes = mutableLinkAttributes
        label?.activeLinkAttributes = mutableActiveLinkAttributes
    }

    static func parseHyperlinks(for label: TTTAttributedLabel?, withText text: String?) {
        var text = text
        var error: Error? = nil
        let aTagRegex = try? NSRegularExpression(pattern: kHTMLATagPattern, options: .caseInsensitive)
        let aTags = aTagRegex?.matches(in: text ?? "", options: [], range: NSRange(location: 0, length: text?.count ?? 0))
        let aHrefRegex = try? NSRegularExpression(pattern: kHTMLAHrefTagPattern, options: .caseInsensitive)

        var urlRangeMapTable = NSMapTable.strongToStrongObjects() as? NSMapTable

        var index = ((aTags?.count ?? 0) - 1)
        while index >= 0 {
            let result: NSTextCheckingResult? = aTags?[index]
            var href: String? = nil
            if let anIndex = result?.range(at: 1) {
                href = (text as NSString?)?.substring(with: anIndex)
            }
            var name: String? = nil
            if let anIndex = result?.range(at: 2) {
                name = (text as NSString?)?.substring(with: anIndex)
            }

            let urlResult: NSTextCheckingResult? = aHrefRegex?.firstMatch(in: href ?? "", options: [], range: NSRange(location: 0, length: href?.count ?? 0))
            var url: String? = nil
            if let anIndex = urlResult?.range(at: 1) {
                url = (href as NSString?)?.substring(with: anIndex)
            }

            let resultRange: NSRange? = result?.range
            var offset: Int = text?.count ?? 0
            if let aRange = resultRange {
                text = (text as NSString?)?.replacingCharacters(in: aRange, with: name ?? "")
            }
            offset -= text?.count ?? 0

            let enumerator: NSEnumerator? = urlRangeMapTable?.keyEnumerator()
            let keys = enumerator?.allObjects

            for key: String? in keys as? [String?] ?? [] {
                var nameRange: NSRange? = urlRangeMapTable?.object(forKey: key)?.rangeValue
                nameRange?.location = UInt(Int(nameRange?.location ?? 0) - offset)
                if let aRange = nameRange {
                    urlRangeMapTable?.setObject(NSValue(range: aRange), forKey: key)
                }
            }

            let nameRange = NSRange(location: Int(resultRange?.location ?? 0), length: name?.count ?? 0)
            urlRangeMapTable?.setObject(NSValue(range: nameRange), forKey: url)
            index -= 1
        }

        label?.text = text
        for url: String? in urlRangeMapTable! {
            let nameRange: NSRange? = urlRangeMapTable?.object(forKey: url)?.rangeValue
            label?.addLink(to: URL(string: url ?? ""), with: nameRange)
        }
    }
}
