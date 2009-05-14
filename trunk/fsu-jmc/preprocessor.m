//
//  preprocessor.m
//  compiler
//
//  Created by Jeff Katz on Sunday 3/1/09.
//

#import "preprocessor.h"
#import "utility.h"

@implementation preprocessor

+ (NSArray*) OpenFile:(const char*) filename
{
	// take a filename and return a raw array of lines
	NSString *tmp;
    NSArray *lines;
    lines = [[NSString stringWithContentsOfFile:[NSString stringWithCString:filename]] 
			 componentsSeparatedByString:@"\n"];
    
    NSEnumerator *nse = [lines objectEnumerator];
    [utility verbose:[NSString stringWithFormat:@"--- Opened file %s:", filename]];
	int i = 1;
    while(tmp = [nse nextObject]) {
        [utility verbose:[NSString stringWithFormat:@"--- %i:\t%@", i++, tmp]];
    }	
	return [lines retain];
}

+ (NSArray*) PreProcess:(NSArray*) lines
{
	// take an array of raw lines and return an array of preprocessed ones 
	NSMutableArray* finished = [[NSMutableArray alloc] init];
	NSString *tmp;
	NSEnumerator *nse = [lines objectEnumerator];
    //[utility verbose:[NSString stringWithFormat:@"Pre-processing %i lines:", [lines count]);
	int i = 1;
    while(tmp = [nse nextObject]) {
		NSString* temp = [self processLine:tmp];
		[finished addObject:temp];
        [utility verbose:[NSString stringWithFormat:@"--- %i:\t%@", i++, temp]];
    }	
	return [finished retain];
}

+ (NSString *) processLine:(NSString*) line
{
	
	// any macro expansions would go here, too
	
	NSString * temp = line;
	NSRange comment = [temp rangeOfString:@"//"];
	if (comment.location != NSNotFound)
	{
		temp = [temp substringToIndex:comment.location]; // pull out comments (like this one!)
	}
	temp = [temp stringByReplacingOccurrencesOfString:@"\\\"" withString:@"ﾞ"]; // handle escaped double quotes in strings properly
	
	NSMutableArray * blah = [temp componentsSeparatedByString:@"\""];
	if ( [blah count] % 2 == 0 ) // syntax error
		return [[blah componentsJoinedByString:@"\""] stringByReplacingOccurrencesOfString:@"ﾞ" withString:@"\\\""]; // todo: error handling properly
	
	NSString* final = [[NSString alloc] init];
	
	for(int i = 0; i < [blah count]; i++) // odd entries are string literals, even ones should be processed normally
	{
		if(i%2 != 0)
		{
			final = [final stringByAppendingString:[NSString stringWithFormat:@"\"%@\"",[blah objectAtIndex:i]]];
			continue;
		}
		NSString* temp = [blah objectAtIndex:i];
		NSString* temp2;
		temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""]; // remove newlines
		temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""]; // remove newlines
		temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""]; // remove tab characters 
		temp2 = [temp stringByReplacingOccurrencesOfString:@"  " withString:@" "]; // remove spurious (more than one) whitespace
		while(![temp2 isEqualToString:temp])
		{
			temp2 = temp; 
			temp = [temp2 stringByReplacingOccurrencesOfString:@"  " withString:@" "]; // remove spurious (more than one) whitespace
		}
		final = [final stringByAppendingString:temp];
	}

	temp = [final stringByReplacingOccurrencesOfString:@"ﾞ" withString:@"\\\""]; // handle escaped double quotes in strings properly
	temp = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // remove any beginning and ending whitespace
	return temp; 
}


@end
