//
//  BrineTestCase.h
//  Brine
//
//  Created by Aaron Sky on 5/2/18.
//

#import <XCTest/XCTest.h>
@import Gherkin;

@class Feature;
@class World;

@protocol BrineTestCaseDelegate
@property (nonatomic, readonly) World *world;
- (Feature *)featureForFeatureClass:(Class)class;
@end

@interface BrineTestCase : XCTestCase

@property (class, nonatomic, weak) id<BrineTestCaseDelegate> classDelegate;

+ (Class)createClassForFeature:(GHFeature *)feature;

+ (NSArray<NSInvocation *> *)testInvocations;
+ (instancetype)testCaseWithSelector:(SEL)selector;
- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber expected:(BOOL)expected;

@end
