#import <XCTest/XCTest.h>
@import Gherkin;

@protocol BrineTestCaseDelegate;

@interface BrineTestCase : XCTestCase

@property (class, nonatomic, weak, nullable) id<BrineTestCaseDelegate> classDelegate;

+ (NSArray<NSInvocation *> *)testInvocations;
+ (instancetype)testCaseWithSelector:(SEL)selector;
- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber expected:(BOOL)expected;

@end
