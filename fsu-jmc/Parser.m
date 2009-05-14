//
//  Parser.m
//  compiler
//
//  Created by Jeff Katz on Tuesday 4/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Parser.h"
#import "tokenizer.h"
#include "stack_additions.h"
#import "utility.h"
#import "Token.h"
#import "CodeGeneration.h"

@implementation Parser
@synthesize error, Accept, tokensCopy, myParseTable;

-(id) initWithTokens: (NSMutableArray *) Stack
{
	if (self = [super init])
	{
		self.tokensCopy = [Stack mutableCopy];
		[self.tokensCopy reverse];
		self.Accept = NO;
		self.myParseTable = [[ParseTable alloc] init];
		self.error = @"Parsing not yet begun";
	}
	
	return self;
	
}
-(CodeGeneration*) parse
{
	NSString* state = [NSString stringWithFormat:@"%d", 0];
	CodeGeneration* cg = [[CodeGeneration alloc] init];
	int lastline = -1;
	
	NSMutableArray* myStack = [[NSMutableArray alloc] init];
	NSDictionary* curMap = [myParseTable.stateTable objectForKey:state];
	
	error = @"No error.";
	Token* token = [tokensCopy pop];
	
	
	[myStack push: [NSArray arrayWithObjects:[NSNumber numberWithInt:token.type], state, token, nil]];
	int action;
	bool amdefault;
	
	int steps = 0;
	
	while(Accept == NO)
	{
		steps++;
		amdefault = NO;
		state = [[myStack lastObject] objectAtIndex:1];
		curMap = [myParseTable.stateTable objectForKey:state];
		int i = [[[myStack lastObject] objectAtIndex:0] intValue];
		id blah = [curMap valueForKey:
		[NSString stringWithFormat:@"%d",i]
				   ];
		
		if (blah == nil)
		{
			id blah2 = [curMap valueForKey:@"888"];
			if(blah2 != nil)
			{
				//[tokensCopy push: token];
				//[myStack push: [NSArray arrayWithObjects:@"888", state, nil]];
				//state = [[myStack lastObject] objectAtIndex:1];
				amdefault = YES;
				blah = blah2;
				goto retinue;
				//continue;
				
			}
			
			NSString* tmz = [[NSString alloc] init];
			
			for(NSString* whole in [curMap allKeys])
				tmz = [tmz stringByAppendingFormat:@"(%@)\t%@\n", whole,  [tokenizer getKeyForNum:[whole intValue]]];
			
			error = [NSString stringWithFormat:@"\nLine %d: Unexpected token %@ (%@) encountered at state (%@). Expected one of: \n%@\n", lastline, [[myStack lastObject] objectAtIndex:0], [[[myStack lastObject] objectAtIndex:2] contents] , state, tmz];			
			break;
		}
		
		
	retinue:
		action = [blah intValue] ; 
		
		lastline = token.line_number;
		if([myStack count] > 0)
			[utility verbose:[NSString stringWithFormat:@"In state: %@, top of stack: %@, action: %d, line %d", state, [tokenizer getKeyForNum:[[[myStack lastObject] objectAtIndex:0] intValue]], action, token.line_number]];
		[utility verbose:[NSString stringWithFormat:@"\tStack is now: "]];
		NSArray* myStackCopy = [[NSMutableArray arrayWithArray:myStack] reverse];
		for(NSArray* wut in myStackCopy)
		{
			[utility verbose:[NSString stringWithFormat:@"\t\tToken: %@\t State: %@\t [%@]", [wut objectAtIndex:0], [wut objectAtIndex:1], [tokenizer getKeyForNum:[[wut objectAtIndex:0] intValue]]]];
		}
		
#pragma mark GOTO		
		if(action > 999) // goto
		{
			[utility verbose:[NSString stringWithFormat:@"Goto-ing...  (new state: %d)", action-1000]];
			[myStack push: [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", token.type], [NSString stringWithFormat:@"%d", action-1000], token, nil]];
			
			continue;
#pragma mark SHIFT			
		} else if (action > -1) // shift
		{

			token = [tokensCopy pop]; 

			if(token == nil) // end of file
			{
				token = [[Token alloc]init];
				token.type = 777;
				token.contents = @"padded $end symbol";
			}
			
			state = [NSString stringWithFormat:@"%d", action];			
			if(!amdefault)
				[myStack push: [NSArray arrayWithObjects:[NSNumber numberWithInt:token.type], state, token, nil]];
			
			[utility verbose:[NSString stringWithFormat:@"Shifting... adding %@ (%@) to stack", [tokenizer getKeyForNum:token.type], token.contents]];
			
			continue;
#pragma mark REDUCE			
		} else if (action > -1000) // reduce
		{
			
			
			NSString* whichrule = [NSString stringWithFormat:@"%d", action*-1];
			
			int howmuch = [[[myParseTable.reduceTable valueForKey:whichrule] objectAtIndex:0] intValue];
			Token* mnToken2 = nil;
			@try {
				mnToken2 = [cg genCodeWithTokens:[NSMutableArray arrayWithArray:myStack] andRule:action*-1];
			}
			
			@catch (NSException* exception) // any errors from the code generation bubble up via exception handling
			{
				
				error = [exception reason];
				Accept=NO;
				return;
				
			}

			
			id blah;
			for(int i = 0; i < howmuch + 1; i++)
				blah = [myStack pop];
 
			if (blah == nil)
				blah = [NSArray arrayWithObjects:@"", @"0", nil]; 
			
			[utility verbose:[NSString stringWithFormat:@"Reducing... (rule %@, pop %d)", whichrule, howmuch + 1]];

			Token* mnToken = [[Token alloc] init];
			mnToken.contents = [[myParseTable.reduceTable valueForKey:whichrule] objectAtIndex:1];
			mnToken.type = [[[tokenizer InitTokens] valueForKey: mnToken.contents] intValue];
			mnToken.line_number = -1;
			
			
			if(mnToken2 != nil)		// only if something special needs to be overridden
				mnToken = mnToken2;
			
			[myStack push: 
			 [NSArray arrayWithObjects:[NSNumber numberWithInt:mnToken.type], [blah objectAtIndex:1], mnToken, nil]
			];
			
			continue;
#pragma mark ACCEPT		
		} else if (action == -1000) // accept
		{			
			error = @"Parsed Correctly.";
			Accept=YES;
			continue;
		}
	}
	
	
	[utility verbose:[NSString stringWithFormat:@"->- Completed parsing in %d steps.", steps]];
	if(Accept)
		return cg;
	else
		return nil;
	

}
@end
