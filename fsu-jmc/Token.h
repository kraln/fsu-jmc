//
//  Token.h
//  compiler
//
//  Created by Jeff Katz on Tuesday 4/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>



@interface Token : NSObject {
	int type;				// what type of token this is
	int line_number;			// where this token came from
	NSString* contents;	// what this token actually said (useful for variables)
	id value;			// token value
	id value_type;		// token value type
}

@property (nonatomic, retain) NSString * contents;
@property (nonatomic, retain) id value;
@property (nonatomic, retain) id value_type;

@property (nonatomic, assign) int type;
@property (nonatomic, assign) int line_number;


@end
