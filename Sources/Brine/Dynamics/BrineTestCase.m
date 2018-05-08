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
        if (scenario.kind == ScenarioKindScenario) {
            [invocations addObject:[[self class] invocationForScenario:scenario inFeature:feature]];
        } else if (scenario.kind == ScenarioKindScenarioOutline) {
            [invocations addObjectsFromArray:[[self class] invocationsForOutline:scenario inFeature:feature]];
        } else if (scenario.kind == ScenarioKindBackground) {
            [feature setBackground:scenario];
        }
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

+ (NSInvocation *)invocationForScenario:(Scenario *)scenario inFeature:(Feature *)feature
{
    NSString *methodName = [@"test" stringByAppendingString:[scenario.name titlecasedString]];
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

+ (NSArray<NSInvocation *> *)invocationsForOutline:(Scenario *)scenario inFeature:(Feature *)feature
{
    NSMutableArray<NSInvocation *> *invocations = [NSMutableArray array];
    for (Example *example in scenario.examples) {
        NSUInteger dataCount = [example.data count];
        for (int i = 0; i < dataCount; i++) {
            [invocations addObject:[[self class] invocationForOutline:scenario
                                                              example:example
                                                                index:i
                                                            inFeature:feature]];
        }
    }
    return invocations;
}

+ (NSInvocation *)invocationForOutline:(Scenario *)scenario example:(Example *)example index:(NSInteger)index inFeature:(Feature *)feature
{
    Scenario *newScenario = [[Scenario alloc]initWithCopy:scenario asOutlineWithExample:example index:index];
    return [[self class] invocationForScenario:newScenario inFeature:feature];
}

@end
