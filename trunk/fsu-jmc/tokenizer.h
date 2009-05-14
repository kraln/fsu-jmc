//
//  tokenizer.h
//  compiler
//
//  Created by Jeff Katz on Sunday 3/1/09.
//

#import <Foundation/Foundation.h>

@interface tokenizer : NSObject {
	NSDictionary* ReservedWords;
	NSMutableArray* TokenStack;
	NSMutableArray* RawTokenStack;
	NSDictionary* Tokens;
}
@property (nonatomic, retain) NSDictionary* Tokens;

@property (nonatomic, retain) NSDictionary* ReservedWords;
@property (nonatomic, retain) NSMutableArray* TokenStack;
@property (nonatomic, retain) NSMutableArray* RawTokenStack;

+(NSMutableDictionary*) InitReservedWords;
+(NSString*) padString:(NSString*) what;
+(NSMutableDictionary*) InitTokens;

+(NSString*) getKeyForNum:(int) num;
-(void)addTokensFromString:(NSString*) source whichWasLineNumber:(int) linenum;

@end
