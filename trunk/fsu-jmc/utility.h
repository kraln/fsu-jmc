//
//  utility.h
//  compiler
//
//  Created by Jeff Katz on Wednesday 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface utility : NSObject {

}

+(void) debug:(NSString*) what;
+(void) verbose:(NSString*) what;
+(void) setDebug:(bool)dbg andVerbose:(bool)avb;
+(void) terrible_error:(NSString*) error where:(NSString*) location;

@end
