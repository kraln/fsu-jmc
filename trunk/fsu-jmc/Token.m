//
//  Token.m
//  compiler
//
//  Created by Jeff Katz on Tuesday 4/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Token.h"


@implementation Token

@synthesize contents,type,line_number,value, value_type;

-(id) init 
{
	if (self = [super init])
	{
		self.type = -1;
		self.contents = @"";
		self.line_number = -1;
		self.value = nil;
		self.value_type = @"NUMERIC";
	}
	
	return self;
}
@end
