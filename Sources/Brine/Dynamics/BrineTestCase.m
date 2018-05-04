//
//  BrineTestCase.m
//  Brine
//
//  Created by Aaron Sky on 5/2/18.
//

#import "BrineTestCase.h"
#import <objc/runtime.h>
#import <Brine/Brine-Swift.h>

OBJC_EXTERN void executeScenario(XCTestCase * self, SEL _cmd, Scenario * scenario, Feature * feature);

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

+ (Class)createClassForFeature:(GHFeature *)feature
{
    NSString * className = [feature.name brine_titlecasedString];
    Class featureClass = objc_allocateClassPair([BrineTestCase class], [className UTF8String], 0);
    if (featureClass == nil) {
        featureClass = NSClassFromString(className);
        while (featureClass == nil) {
            className = [className stringByAppendingFormat:@"%lu", [@1 unsignedLongValue]];
            featureClass = objc_allocateClassPair([BrineTestCase class], [className UTF8String], 0);
        }
    }
    objc_registerClassPair(featureClass);
    return featureClass;
}

+ (NSArray<NSInvocation *> *)testInvocations
{
    Feature *feature = [_classDelegate featureForFeatureClass:[self class]];
    return [[self class] invocationsForFeature:feature];
}

+ (instancetype)testCaseWithSelector:(SEL)selector
{
    return [self testCaseWithSelector:selector];
}

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber expected:(BOOL)expected
{
    [super recordFailureWithDescription:description inFile:filePath atLine:lineNumber expected:expected];
}

+ (NSArray<NSInvocation *> *)invocationsForFeature:(Feature *)feature
{
    NSMutableArray *array = [NSMutableArray array];
    for (Scenario *scenario in feature.scenarios) {
        [array addObject:[[self class] invocationForScenario:scenario inFeature:feature]];
    }
    return array;
}

+ (NSInvocation *)invocationForScenario:(Scenario *)scenario inFeature:(Feature *)feature
{
    NSString *methodName = [scenario.name brine_titlecasedString];
    SEL selector = NSSelectorFromString(methodName);
    class_addMethod([self class], selector, (IMP)executeScenario, [@"v@:@:@" UTF8String]);
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setArgument:&scenario atIndex:2];
    [invocation setArgument:&feature atIndex:3];
    [invocation retainArguments];
    return invocation;
}

@end

void executeScenario(BrineTestCase * self, SEL _cmd, Scenario * scenario, Feature * feature)
{
    World *world = [_classDelegate world];
    [scenario runIn:world];
}

