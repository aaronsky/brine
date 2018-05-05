#import "BrineTestCase.h"
#import <objc/runtime.h>
#import <Brine/Brine-Swift.h>

@implementation BrineTestCase

static id<BrineTestCaseDelegate> _classDelegate = nil;

+ (id<BrineTestCaseDelegate>)classDelegate {
    return _classDelegate;
}

+ (void)setClassDelegate:(id<BrineTestCaseDelegate>)delegate
{
    _classDelegate = delegate;
}

#pragma mark – XCTest Integration

+ (NSArray<NSInvocation *> *)testInvocations
{
    Feature *feature = [_classDelegate featureForFeatureClass:[self class]];
    NSMutableArray<NSInvocation *> *invocations = [NSMutableArray array];
    for (Scenario *scenario in feature.scenarios) {
        [invocations addObject:[[self class] invocationForScenario:scenario inFeature:feature]];
    }
    return invocations;
}

+ (instancetype)testCaseWithSelector:(SEL)selector
{
    Feature *feature = [_classDelegate featureForFeatureClass:[self class]];
    BrineTestCase *invocationTest;
    
    for (Scenario *scenario in feature.scenarios) {
        NSString *scenarioName = NSStringFromSelector(selector);
        if ([scenario.name isEqualToString:scenarioName]) {
            NSInvocation *invocation = [[self class] invocationForScenario:scenario inFeature:feature];
            invocationTest = [[self alloc] initWithInvocation:invocation];
            break;
        }
    }
    return invocationTest;
}

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber expected:(BOOL)expected
{
    if ([filePath hasSuffix:@".feature"]) {
        [self recordFailureWithDescription:description inFile:filePath atLine:lineNumber expected:expected];
    } else {
        // throwException
    }
}

+ (NSInvocation *)invocationForScenario:(Scenario *)scenario inFeature:(Feature *)feature
{
    NSString *methodName = [scenario.name titlecasedString];
    SEL selector = NSSelectorFromString(methodName);
    [[self class] addMethodFor:selector];
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setArgument:&scenario atIndex:2];
    [invocation setArgument:&feature atIndex:3];
    [invocation retainArguments];
    return invocation;
}

@end
