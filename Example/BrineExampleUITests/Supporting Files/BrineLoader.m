
#import <Foundation/Foundation.h>
#import "BrineExampleUITests-Swift.h"

__attribute__((constructor))
void BrineInit(){
    TestDriver *driver = [[TestDriver alloc] init];
    [driver start];
}

