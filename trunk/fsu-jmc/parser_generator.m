//
//  parser_generator.m
//  compiler
//
//  Created by Jeff Katz on Tuesday 4/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tokenizer.h"
#import "utility.h"

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	tokenizer* t = [[tokenizer alloc] init];
	
	NSString* fileContents = [NSString stringWithContentsOfFile:@"/Users/jeff/Projects/compiler/mpp.output"]; // hardcoded.
	NSArray* lines = [fileContents componentsSeparatedByString:@"\n"];
	
	// you have to remove the first lines (with 'grammar') 
	// and the listings of terminals and nonterminals
	// before running this
	
	
	int i = 0;
	bool state = YES;
	int curstate = 0;
	
	NSString * file = [NSString stringWithContentsOfFile:@"/Users/jeff/Projects/compiler/parser.head"];
		
	NSString* lastProdName = @"";
	for(NSString* line in lines)
	{
		
		i++;		
		
		NSString* temp = line;
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
		
		NSArray* arr = [[temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if([[arr objectAtIndex:0] isEqualToString:@"state"])
			state = NO;
		
		if(state)
		{
			
			if([arr count] < 2)
				continue;
			
			if([((NSString*)[arr objectAtIndex:1]) rangeOfString:@":"].location != NSNotFound)
			{
				lastProdName = [arr objectAtIndex:1];
			}
			NSString*  prodName = [lastProdName substringToIndex:[lastProdName length]-1];
			
			file = [file stringByAppendingFormat:@"	[temp setObject:[NSArray arrayWithObjects:@\"%d\", @\"%@\", nil] forKey:@\"%d\"]; \n", [arr count] - 2, prodName, [[arr objectAtIndex:0] intValue]];
			[utility debug:[NSString stringWithFormat:@"Reduce Rule #%02d: Pop #%d", [[arr objectAtIndex:0] intValue], [arr count] - 2]];
			
			
		} else 
		{
			if([arr count] < 2)
				continue;
			
			if([[arr objectAtIndex:0] isEqualToString:@"state"])
			{
				file = [file stringByAppendingFormat:@"[temp2 setValue:temp3 forKey:@\"%d\"]; \ntemp3 = [[NSMutableDictionary alloc] init]; \n", curstate];
				curstate = [[arr objectAtIndex:1] intValue];
				continue;
			}
			
			if([[arr objectAtIndex:1] isEqualToString:@"shift,"])
			{
				file = [file stringByAppendingFormat:@"[temp3 setValue:@\"%d\" forKey:@\"%d\"]; \n",[[arr objectAtIndex:6] intValue],  [[t.Tokens valueForKey:[arr objectAtIndex:0]] intValue] ];

				//[utility debug:[NSString stringWithFormat:@"{%d, %d, %d}", curstate, [[t.Tokens valueForKey:[arr objectAtIndex:0]] intValue], [[arr objectAtIndex:6] intValue]);
				continue;
			} else if([[arr objectAtIndex:1] isEqualToString:@"go"])
			{
				//[utility debug:[NSString stringWithFormat:@"{%d, %d, %d}", curstate, [[t.Tokens valueForKey:[arr objectAtIndex:0]] intValue], [[arr objectAtIndex:4] intValue] + 1000);
				file = [file stringByAppendingFormat:@"[temp3 setValue:@\"%d\" forKey:@\"%d\"]; \n",[[arr objectAtIndex:4] intValue] + 1000,  [[t.Tokens valueForKey:[arr objectAtIndex:0]] intValue] ];

				continue;
			} else if([[arr objectAtIndex:1] isEqualToString:@"reduce"])
			{
				//[utility debug:[NSString stringWithFormat:@"{%d, %d, %d}", curstate, [[t.Tokens valueForKey:[arr objectAtIndex:0]] intValue], [[arr objectAtIndex:4] intValue] * -1);
				file = [file stringByAppendingFormat:@"[temp3 setValue:@\"%d\" forKey:@\"%d\"]; \n",[[arr objectAtIndex:4] intValue]*-1,  [[t.Tokens valueForKey:[arr objectAtIndex:0]] intValue] ];

				continue;
			} else if([[arr objectAtIndex:1] isEqualToString:@"accept"])
			{
				file = [file stringByAppendingFormat:@"[temp3 setObject:@\"%d\" forKey:@\"%d\"]; \n", -1000,  [[t.Tokens valueForKey:[arr objectAtIndex:0]] intValue] ];

				//[utility debug:[NSString stringWithFormat:@"{%d, %d, %d}", curstate, [[t.Tokens valueForKey:[arr objectAtIndex:0]] intValue], -1000);
				continue;
			} 
			
		}
		
	}
	
	file = [file stringByAppendingFormat:@" reduceTable = [NSDictionary dictionaryWithDictionary:temp];\n stateTable = [NSDictionary dictionaryWithDictionary:temp2]; 	} return self; } @end"];
	//[utility debug:[NSString stringWithFormat:@"Output: %@", file);
	
	[file writeToFile:@"/Users/jeff/Projects/compiler/compiler/ParseTable.m" atomically:FALSE];
	[pool drain];
	return 0;
}