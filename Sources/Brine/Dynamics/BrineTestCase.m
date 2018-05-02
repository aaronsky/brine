//
//  BrineTestCase.m
//  Brine
//
//  Created by Aaron Sky on 5/2/18.
//

#import "BrineTestCase.h"
#import <objc/runtime.h>

@implementation BrineTestCase

#pragma mark – XCTest Integration

+ (Class)createClassForFeature:(GHFeature *)feature
{
    NSString * className = [[feature.name capitalizedString] stringByReplacingOccurrencesOfString:@"\\s"
                                                                                       withString:@""
                                                                                          options:NSRegularExpressionSearch
                                                                                            range:NSMakeRange(0, [feature.name length])];
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
    return [super testInvocations];
}

+ (instancetype)testCaseWithSelector:(SEL)selector
{
    return [self testCaseWithSelector:selector];
}

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber expected:(BOOL)expected
{
    [super recordFailureWithDescription:description inFile:filePath atLine:lineNumber expected:expected];
}

@end
