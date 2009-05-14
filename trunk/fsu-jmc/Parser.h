//
//  Parser.h
//  compiler
//
//  Created by Jeff Katz on Tuesday 4/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ParseTable.h"
#import "CodeGeneration.h"

@interface Parser : NSObject {
	bool Accept;
	NSString* error;
	NSMutableArray* tokensCopy;
	ParseTable* myParseTable;
}

@property(nonatomic, assign) bool Accept;
@property(nonatomic, retain) NSString* error;
@property(nonatomic, retain) NSMutableArray* tokensCopy;
@property(nonatomic, retain) ParseTable* myParseTable;

-(id) initWithTokens: (NSMutableArray *) Stack;
-(CodeGeneration*) parse;
@end
