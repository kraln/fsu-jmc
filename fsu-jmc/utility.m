//
//  utility.m
//  compiler
//
//  Created by Jeff Katz on Wednesday 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "utility.h"


@implementation utility
bool verbose, debug;

+(void) setDebug:(bool)dbg andVerbose:(bool)avb
{
	verbose = avb;
	debug = dbg;
}
+(void) debug:(NSString*) what
{
	if(debug)
		printf("%s\n", [what UTF8String]);
}

+(void) verbose:(NSString*) what
{
	if(verbose)
		[self debug:what];
}

+(void) terrible_error:(NSString*)error where:(NSString*) location
{
	debug = YES;
	[self debug:[NSString stringWithFormat:@"Unrecoverable error in %@ module: %@", location, error]];
	
}

@end
