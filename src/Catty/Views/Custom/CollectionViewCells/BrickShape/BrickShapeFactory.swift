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

import Foundation
import UIKit

class BrickShapeFactory: NSObject {
    // Drawing Methods

    static func drawLargeRoundedControlBrickShape(withFill fillColor: UIColor?, stroke strokeColor: UIColor?, height: CGFloat, width: CGFloat) {
        //// Frames
        var frame = CGRect(x: 0, y: 0, width: width, height: height - 8)

        //// Subframes
        let group = CGRect(x: frame.minX + 15, y: frame.minY + frame.height - 6.1, width: 20, height: 10.6)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.21952 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.21250 * frame.width, y: frame.minY + 0.5), controlPoint1: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.21952 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.07750 * frame.width, y: frame.minY + 0.5))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.55250 * frame.width, y: frame.minY + 0.34865 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.34750 * frame.width, y: frame.minY + 0.5), controlPoint2: CGPoint(x: frame.minX + 0.55250 * frame.width, y: frame.minY + 0.34865 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.maxX - 0.66, y: frame.minY + 0.34865 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.maxX - 0.66, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 36.5, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 18.5, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.maxY - 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.21952 * frame.height))
        bezierPath.close()
        bezierPath.lineCapStyle = .round

        bezierPath.lineJoinStyle = .round

        fillColor?.setFill()
        bezierPath.fill()
        strokeColor?.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()

        /*
         //// Bezier 2 Drawing
         UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
         [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 16, CGRectGetMinY(frame) + 0.46063 * CGRectGetHeight(frame))];
         [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 0.46063 * CGRectGetHeight(frame))];
         [fillColor setFill];
         [bezier2Path fill];
         [strokeColor setStroke];
         bezier2Path.lineWidth = 1;
         [bezier2Path stroke];


         //// Bezier 3 Drawing
         UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
         [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 16, CGRectGetMinY(frame) + 0.57763 * CGRectGetHeight(frame))];
         [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 0.57763 * CGRectGetHeight(frame))];
         [fillColor setFill];
         [bezier3Path fill];
         [strokeColor setStroke];
         bezier3Path.lineWidth = 1;
         [bezier3Path stroke];


         //// Bezier 4 Drawing
         UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
         [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 16, CGRectGetMinY(frame) + 0.69436 * CGRectGetHeight(frame))];
         [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 0.69436 * CGRectGetHeight(frame))];
         [fillColor setFill];
         [bezier4Path fill];
         [strokeColor setStroke];
         bezier4Path.lineWidth = 1;
         [bezier4Path stroke];
         */

        self.drawThreeLeftLines(inFrame: frame, fill: fillColor, stroke: strokeColor, brickHeight: height)

        //// Group
        do {
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath()
            rectanglePath.move(to: CGPoint(x: group.minX + 0.8, y: group.minY + 10.6))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 19.2, y: group.minY + 10.6))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 19.2, y: group.minY + 1.5))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 0.8, y: group.minY + 1.5))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 0.8, y: group.minY + 10.6))
            rectanglePath.close()
            rectanglePath.lineCapStyle = .round

            rectanglePath.lineJoinStyle = .round

            fillColor?.setFill()
            rectanglePath.fill()
            strokeColor?.setStroke()
            rectanglePath.lineWidth = 1
            rectanglePath.stroke()

            //// Rectangle 2 Drawing
            let rectangle2Path = UIBezierPath(rect: CGRect(x: group.minX, y: group.minY, width: 20, height: 5))
            fillColor?.setFill()
            rectangle2Path.fill()
        }
    }

    static func drawSquareBrickShape(withFill fillColor: UIColor?, stroke strokeColor: UIColor?, height: CGFloat, width: CGFloat) {

        //// Frames
        var frame = CGRect(x: 0, y: 0, width: width, height: height - 0.5)

        //// Subframes
        let group = CGRect(x: frame.minX + 15, y: frame.minY + frame.height - 6.1, width: 20, height: 10.6)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 14.5, y: frame.minY + 0.46))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 14.5, y: frame.minY + 5.44))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 35.5, y: frame.minY + 5.44))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 35.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + 0.03))
        bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 36.62, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 18.56, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.maxY - 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.close()
        bezierPath.lineCapStyle = .round

        bezierPath.lineJoinStyle = .round

        fillColor?.setFill()
        bezierPath.fill()
        strokeColor?.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()

        self.drawThreeLeftLines(inFrame: frame, fill: fillColor, stroke: strokeColor, brickHeight: height)

        //// Group
        do {
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath()
            rectanglePath.move(to: CGPoint(x: group.minX + 0.8, y: group.minY + 10.6))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 19.2, y: group.minY + 10.6))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 19.2, y: group.minY + 1.5))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 0.8, y: group.minY + 1.5))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 0.8, y: group.minY + 10.6))
            rectanglePath.close()
            rectanglePath.lineCapStyle = .round

            rectanglePath.lineJoinStyle = .round

            fillColor?.setFill()
            rectanglePath.fill()
            strokeColor?.setStroke()
            rectanglePath.lineWidth = 1
            rectanglePath.stroke()


            //// Rectangle 2 Drawing
            let rectangle2Path = UIBezierPath(rect: CGRect(x: group.minX, y: group.minY, width: 20, height: 5))
            fillColor?.setFill()
            rectangle2Path.fill()
        }
    }

    static func drawEndForeverLoopShape1(withFill fillColor: UIColor?, stroke strokeColor: UIColor?, height: CGFloat, width: CGFloat) {
        //// Frames
        var frame = CGRect(x: 0, y: 0, width: width, height: height - 0.5)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 14.5, y: frame.minY + 0.46))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 14.5, y: frame.minY + 5.44))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 35.5, y: frame.minY + 5.44))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 35.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + 0.03))
        bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 36.62, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 18.56, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.maxY - 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.close()
        bezierPath.lineCapStyle = .round

        bezierPath.lineJoinStyle = .round

        fillColor?.setFill()
        bezierPath.fill()
        strokeColor?.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()

        self.drawThreeLeftLines(inFrame: frame, fill: fillColor, stroke: strokeColor, brickHeight: height)
    }

    static func drawEndForeverLoopShape2(withFill fillColor: UIColor?, stroke strokeColor: UIColor?, height: CGFloat, width: CGFloat) {

        //// Frames
        var frame = CGRect(x: 0, y: 0, width: width, height: height - 0.5)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 14.5, y: frame.minY + 0.46))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 18.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 32.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 35.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + 0.03))
        bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 36.62, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 18.56, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.maxY - 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.close()
        bezierPath.lineCapStyle = .round

        bezierPath.lineJoinStyle = .round

        fillColor?.setFill()
        bezierPath.fill()
        strokeColor?.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()

        self.drawThreeLeftLines(inFrame: frame, fill: fillColor, stroke: strokeColor, brickHeight: height)
    }

    static func drawEndForeverLoopShape3(withFill fillColor: UIColor?, stroke strokeColor: UIColor?, height: CGFloat, width: CGFloat) {

        //// Frames
        var frame = CGRect(x: 0, y: 0, width: width, height: height - 0.5)

        //// Subframes
        let group = CGRect(x: frame.minX + 15, y: frame.minY + frame.height - 6.1, width: 20, height: 10.6)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 14.5, y: frame.minY + 0.46))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 18.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 28.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 35.5, y: frame.minY + 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + 0.03))
        bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 36.62, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 18.56, y: frame.maxY - 0.59))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.maxY - 0.5))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.5, y: frame.minY + 0.5))
        bezierPath.close()
        bezierPath.lineCapStyle = .round

        bezierPath.lineJoinStyle = .round

        fillColor?.setFill()
        bezierPath.fill()
        strokeColor?.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()

        self.drawThreeLeftLines(inFrame: frame, fill: fillColor, stroke: strokeColor, brickHeight: height)

        //// Group
        do {
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath()
            rectanglePath.move(to: CGPoint(x: group.minX + 0.8, y: group.minY + 10.6))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 19.2, y: group.minY + 10.6))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 19.2, y: group.minY + 1.5))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 0.8, y: group.minY + 1.5))
            rectanglePath.addLine(to: CGPoint(x: group.minX + 0.8, y: group.minY + 10.6))
            rectanglePath.close()
            rectanglePath.lineCapStyle = .round

            rectanglePath.lineJoinStyle = .round

            fillColor?.setFill()
            rectanglePath.fill()
            strokeColor?.setStroke()
            rectanglePath.lineWidth = 1
            rectanglePath.stroke()

            //// Rectangle 2 Drawing
            let rectangle2Path = UIBezierPath(rect: CGRect(x: group.minX, y: group.minY, width: 20, height: 5))
            fillColor?.setFill()
            rectangle2Path.fill()
        }
    }

    // MARK: Initialization

    /* TODO: CONVERT override func initialize() {
    }*/

    // MARK: Drawing Methods

    static func drawThreeLeftLines(inFrame frame: CGRect?, fill fillColor: UIColor?, stroke strokeColor: UIColor?, brickHeight height: CGFloat) {
        var gap: CGFloat = 0.0
        var firstLine: CGFloat = 0.0
        var secondLine: CGFloat = 0.0
        var thirdLine: CGFloat = 0.0

        let frameHeigth = frame?.height

        if (Double(height) != Double(roundedLargeBrick)) && (Double(height) != Double(roundedSmallBrick)) {
            gap = CGFloat((Double(frameHeigth!) - Double(smallBrick)) / 2.0)
        } else {
            gap = 0.3 * (frame?.height)!
            //TODO gap = CGFloat(Double(gap) + ((1 - 0.3) * frame?.height - smallBrick) / 2.0)
        }
        firstLine = CGFloat(0.40238 * smallBrick)
        secondLine = CGFloat(0.50442 * smallBrick)
        thirdLine = CGFloat(0.60647 * smallBrick)

        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: (frame?.minX)! + 16, y: (frame?.minY)! + gap + firstLine))
        bezier2Path.addLine(to: CGPoint(x: (frame?.minX)! + 34, y: (frame?.minY)! + gap + firstLine))
        fillColor?.setFill()
        bezier2Path.fill()
        strokeColor?.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()

        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: (frame?.minX)! + 16, y: (frame?.minY)! + gap + secondLine))
        bezier3Path.addLine(to: CGPoint(x: (frame?.minX)! + 34, y: (frame?.minY)! + gap + secondLine))
        fillColor?.setFill()
        bezier3Path.fill()
        strokeColor?.setStroke()
        bezier3Path.lineWidth = 1
        bezier3Path.stroke()

        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: (frame?.minX)! + 16, y: (frame?.minY)! + gap + thirdLine))
        bezier4Path.addLine(to: CGPoint(x: (frame?.minX)! + 34, y: (frame?.minY)! + gap + thirdLine))
        fillColor?.setFill()
        bezier4Path.fill()
        strokeColor?.setStroke()
        bezier4Path.lineWidth = 1
        bezier4Path.stroke()
    }
}
