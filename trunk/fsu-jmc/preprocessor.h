//
//  preprocessor.h
//  compiler
//
//  Created by Jeff Katz on Sunday 3/1/09.
//

#import <Foundation/Foundation.h>


@interface preprocessor : NSObject {

}

+(NSArray*) OpenFile:(const char*) filename;	// open a file into an array
+(NSArray*) PreProcess:(NSArray*) lines;		// preprocess an array of lines into an array
+(NSString *) processLine:(NSString*) line;		// preprocess one line 

@end
