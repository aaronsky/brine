#import <Foundation/Foundation.h>
#import "GHGherkinLineProtocol.h"

@class GHGherkinLineSpan;
@class GHGherkinDialect;
@class GHLocation;

#import "GHAstNode.h"

@interface GHToken : NSObject

@property (nonatomic, readonly, getter=isEOF) BOOL          eof;
@property (nullable, nonatomic, strong) id<GHGherkinLineProtocol>     line;
@property (nonatomic, assign) GHTokenType                   matchedType;
@property (nonatomic, strong) NSString                      * matchedKeyword;
@property (nonatomic, strong) NSString                      * matchedText;
@property (nonatomic, strong) NSArray<GHGherkinLineSpan *>  * matchedItems;
@property (nonatomic, assign) NSUInteger                    matchedIndent;
@property (nullable, nonatomic, strong) GHGherkinDialect              * matchedGherkinDialect;
@property (nonatomic, strong) GHLocation                    * location;

- (id)initWithGherkinLine:(nullable id<GHGherkinLineProtocol>)theGherkinLine location:(GHLocation *)theLocation;
- (void)detach;
- (NSString *)tokenValue;

@end
