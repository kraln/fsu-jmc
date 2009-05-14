//
//  CodeGeneration.h
//  compiler
//
//  Created by Jeff Katz on Tuesday 4/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Token.h"
#import "tokenizer.h"

@interface CodeGeneration : NSObject {

	int						curQ;
	NSMutableDictionary*	OutputLines;
	tokenizer*				tokenIzer;
	NSMutableArray*	ifStack;
	NSMutableArray*	whileStack;
	NSMutableArray* idStack;
	NSMutableDictionary*	symLookup;
	NSMutableDictionary*	symStrings;

}

@property (nonatomic, assign)	int curQ;
@property (nonatomic, retain)	NSMutableDictionary* OutputLines;
@property (nonatomic, retain)	NSMutableDictionary* symLookup;
@property (nonatomic, retain)	NSMutableDictionary* symStrings;

@property (nonatomic, retain)	tokenizer* tokenIzer;
@property (nonatomic, retain)	NSMutableArray*	ifStack;
@property (nonatomic, retain)	NSMutableArray*	idStack;
@property (nonatomic, retain)	NSMutableArray*	whileStack;

-(NSString*) stringValue;
-(Token*) genCodeWithTokens:(NSMutableArray*) tStack andRule:(int) rule;
@end
