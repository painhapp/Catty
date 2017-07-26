/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "XMLParserBrickTests093.h"
#import "CBXMLParserHelper.h"
#import "ChangeVariableBrick+CBXMLHandler.h"

@interface XMLParserBrickTests0992 : XMLAbstractTest
@property (nonatomic, strong) CBXMLParserContext *parserContext;
@property (nonatomic, strong) CBXMLSerializerContext *serializerContext;
@end

@implementation XMLParserBrickTests0992

- (void)setUp
{
    self.parserContext = [[CBXMLParserContext alloc] initWithLanguageVersion:0.992f];
    self.serializerContext = [[CBXMLSerializerContext alloc] init];
}

- (void)testInvalidSetVariableBrickWithoutFormula
{
    SetVariableBrick *setVariableBrick = [SetVariableBrick new];
    GDataXMLElement *xmlElement = [setVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertThrowsSpecificNamed([SetVariableBrick parseFromElement:xmlElement withContext:self.parserContext], NSException, NSStringFromClass([CBXMLParserHelper class]), @"SetVariableBrick has invalid number of formulas. Should throw exception.");
}

- (void)testSetVariableBrickWithoutInUserBrickElement
{
    SetVariableBrick *setVariableBrick = [SetVariableBrick new];
    [setVariableBrick setDefaultValuesForObject:nil];
    GDataXMLElement *xmlElement = [setVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    XCTAssertNil([xmlElement childWithElementName:@"inUserBrick"], @"inUserBrickElement element should not be found");
    
    SetVariableBrick *parsedSetVariableBrick = [SetVariableBrick parseFromElement:xmlElement withContext:self.parserContext];
    
    XCTAssertNotNil(parsedSetVariableBrick, @"Could not parse SetVariableBrick");
    XCTAssertNotNil(parsedSetVariableBrick.variableFormula, @"Formula not correctly parsed");
}

- (void)testChangeVariableBrickWithoutInUserBrickElement
{
    ChangeVariableBrick *changeVariableBrick = [ChangeVariableBrick new];
    [changeVariableBrick setDefaultValuesForObject:nil];
    GDataXMLElement *xmlElement = [changeVariableBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    XCTAssertNil([xmlElement childWithElementName:@"inUserBrick"], @"inUserBrickElement element should not be found");
    
    ChangeVariableBrick *parsedChangeVariableBrick = [ChangeVariableBrick parseFromElement:xmlElement withContext:self.parserContext];
    
    XCTAssertNotNil(parsedChangeVariableBrick, @"Could not parse ChangeVariableBrick");
    XCTAssertNotNil(parsedChangeVariableBrick.variableFormula, @"Formula not correctly parsed");
}

- (void)testShowBrickWithoutInUserBrickElement
{
    ShowBrick *showBrick = [ShowBrick new];
    [showBrick setDefaultValuesForObject:nil];
    GDataXMLElement *xmlElement = [showBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    XCTAssertNil([xmlElement childWithElementName:@"inUserBrick"], @"inUserBrickElement element should not be found");
}

- (void)testHideBrickWithoutInUserBrickElement
{
    HideBrick *hideBrick = [HideBrick new];
    [hideBrick setDefaultValuesForObject:nil];
    GDataXMLElement *xmlElement = [hideBrick xmlElementWithContext:self.serializerContext];
    
    XCTAssertNotNil(xmlElement, @"GDataXMLElement must not be nil");
    XCTAssertNil([xmlElement childWithElementName:@"inUserBrick"], @"inUserBrickElement element should not be found");
}

@end
