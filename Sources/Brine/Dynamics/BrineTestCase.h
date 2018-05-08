@import XCTest;

@protocol BrineTestCaseDelegate;

@interface BrineTestCase : XCTestCase

@property (class, nonatomic, weak, nullable) id<BrineTestCaseDelegate> classDelegate;
@property (class, readonly, copy) NSArray<NSInvocation *> *testInvocations;

+ (nullable instancetype)testCaseWithSelector:(SEL)selector;

@end
