//
//  BrineTestCase.h
//  Brine
//
//  Created by Aaron Sky on 5/2/18.
//

#import <XCTest/XCTest.h>
@import Gherkin;

@interface BrineTestCase : XCTestCase

+ (Class)createClassForFeature:(GHFeature *)feature;

+ (NSArray<NSInvocation *> *)testInvocations;
+ (instancetype)testCaseWithSelector:(SEL)selector;
- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber expected:(BOOL)expected;

@end
