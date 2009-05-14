//
//  CodeGeneration.m
//  compiler
//
//  Created by Jeff Katz on Tuesday 4/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CodeGeneration.h"
#import "Token.h"
#import "tokenizer.h"
#import "stack_additions.h"

@implementation CodeGeneration

@synthesize curQ, OutputLines, tokenIzer, ifStack, whileStack, symLookup, symStrings, idStack;

-(id) init 
{
	if (self = [super init])
	{
		self.tokenIzer = [[tokenizer alloc] init];
		self.curQ = -1; // current quad 
		self.OutputLines = [[NSMutableDictionary alloc] init]; // output statements hashed by line
		self.ifStack = [[NSMutableArray alloc] init]; // stack of backpatch for if statements
		self.whileStack = [[NSMutableArray alloc] init]; // stack of backpatch for while statements
		self.idStack = [[NSMutableArray alloc] init]; // used for each declaration
		self.symLookup = [[NSMutableDictionary alloc] init]; 
		self.symStrings = [[NSMutableDictionary alloc] init];
		// contains an hash table of ID to Type (NSString*), TempID(NSNumber*)
	}
	return self;
}


-(Token*) genCodeWithTokens:(NSMutableArray*) tStack andRule:(int) rule
{

	static int tempreg = 0;
	Token* newToken = [[Token alloc] init];
	NSDictionary* lookup = [tokenizer InitTokens];
	[tStack pop];

	id aT;
	id bT;
	
	newToken.line_number = -1;
	NSString* a0, *a1,* a2,* a3;
	NSString* a, *b,* o;
	NSString* key;
	NSMutableArray *vals;
	NSMutableArray *vals2;
	int x, y;
	switch (rule)
	{ 

			
		case 4:		//4		identifier_list: ID
			
		case 5:		//5		| identifier_list ',' ID

			[idStack push:((Token*)[[tStack pop] objectAtIndex:2]).contents];

			// push ID onto the sym stack
			
			return nil;
			
		
		case 7:		//     7 declarations: declarations VAR identifier_list ':' type ';'

			// pop all the ids from id stack, assigning a temp variable to them
			// set the types of all the IDs in the symLookup table to 'type'
			[tStack pop];
			key = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			
			for(NSString* t in idStack)
			{
				NSArray* z = [[NSArray alloc] initWithObjects: key, [NSNumber numberWithInt:++tempreg], nil];
				[symLookup setValue:z forKey:t];
			}
			
			[idStack release];
			idStack = [[NSMutableArray alloc] init];
			
			return nil;
			
			
		case 9: // type -> standard_type
			newToken.type = [[lookup objectForKey:@"type"] intValue];
			newToken.contents = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			newToken.value_type = newToken.contents;
			return [newToken retain];
			
		case 10: // type -> String
			newToken.type = [[lookup objectForKey:@"type"] intValue];
			newToken.contents = @"STRING";
			newToken.value_type = newToken.contents;
			return [newToken retain];
		case 11:
		case 13:
		case 12:
		case 14:
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.type = [[lookup objectForKey:@"standard_type"] intValue];
			newToken.contents = [aT contents];
			newToken.value_type = newToken.contents;
			return [newToken retain];
			
			
		case 24: // statement -> read '(' id ')'
			[tStack pop];
			aT = [tStack pop];
			//SYS #1, ,0

			if ([[[aT objectAtIndex:2] value_type] isEqualToString:@"STRING"])
				[NSException raise:@"Variable Error" format:@"Variable error line #%i: Tried to read a value into ID %@ (which was declared as a string).", [aT line_number], [aT contents]];

			
			if ([symLookup valueForKey:[[aT objectAtIndex:2] contents]] == nil)
				[NSException raise:@"Variable Error" format:@"Variable error line #%i: Tried to read a value into ID %@ (which was never declared).", [aT line_number], [aT contents]];

			
			a0 = @"SYS"; // unconditional jump
			a1 = @"#1";
			a2 = @"";
			a3 = [NSString stringWithFormat:@"T%@",[[symLookup valueForKey:[[aT objectAtIndex:2] contents]] objectAtIndex:1]];
			
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];	
					
			return nil;
		case 25: // statement -> write '(' id ')'	
			[tStack pop];
			aT = [tStack pop];
			//SYS #-2,0,<CONTENTS OF ID> 
						
			if ([symLookup valueForKey:[[aT objectAtIndex:2] contents]] == nil)
				[NSException raise:@"Variable Error" format:@"Variable error line #%i: Tried to write a value from ID %@ (which was never declared).", [aT line_number], [aT contents]];

			if ([[[symLookup valueForKey:[[aT objectAtIndex:2] contents]] objectAtIndex:0] isEqualToString:@"STRING"])
			{
				
				
				//NSLog(@"Outputting a string...");
				o = [symStrings valueForKey:[[aT objectAtIndex:2] contents]];
				if (o == nil)
				[NSException raise:@"Variable Error" format:@"Variable error line #%i: Tried to write a value from ID %@ (which was never set).", [aT line_number], [aT contents]];

				for(int iz = 1; iz < ([o length] - 1); iz++)
				{
					if (([o characterAtIndex:iz] == [@"␤" characterAtIndex:0]))
					{
						a0 = @"SYS"; 
						a1 = @"#0";
						a2 = @"";
						a3 = @"";
						key = [NSString stringWithFormat:@"%d", curQ+=1];
						vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
						[self.OutputLines setObject:vals forKey:key];	
						
					} else {
					a0 = @"SYS"; 
					a1 = @"#-2";
					a2 = [NSString stringWithFormat:@"#%i",[o characterAtIndex:iz]];
					a3 = @"";
					key = [NSString stringWithFormat:@"%d", curQ+=1];
					vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
					[self.OutputLines setObject:vals forKey:key];	
					}
				}
				
								
				return nil;
			} else if (([[[symLookup valueForKey:[[aT objectAtIndex:2] contents]] objectAtIndex:0] isEqualToString:@"INT"])||([[[symLookup valueForKey:[[aT objectAtIndex:2] contents]] objectAtIndex:0] isEqualToString:@"SHORT"])) {
				a0 = @"SYS"; 
				a1 = @"#-1";
				a2 = [NSString stringWithFormat:@"T%@",[[symLookup valueForKey:[[aT objectAtIndex:2] contents]] objectAtIndex:1]];
				a3 = @"";
				
				key = [NSString stringWithFormat:@"%d", curQ+=1];
				vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
				[self.OutputLines setObject:vals forKey:key];	
				
				return nil;
			
			} else if ([[[symLookup valueForKey:[[aT objectAtIndex:2] contents]] objectAtIndex:0] isEqualToString:@"BOOLEAN"]) {
				
				a0 = @"JEQ"; 
				a1 = @"#0";
				a2 = [NSString stringWithFormat:@"T%@",[[symLookup valueForKey:[[aT objectAtIndex:2] contents]] objectAtIndex:1]];
				a3 = [NSString stringWithFormat:@"#%d", curQ+4];
				
				key = [NSString stringWithFormat:@"%d", curQ+=1];
				vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
				[self.OutputLines setObject:vals forKey:key];	
				
				a0 = @"SYS";
				a1 = @"#-1";
				a2 = @"#1";
				a3 = @"";
				
				key = [NSString stringWithFormat:@"%d", curQ+=1];
				vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
				[self.OutputLines setObject:vals forKey:key];	
				
				a0 = @"JMP";
				a1 = @"";
				a2 = @"";
				a3 = [NSString stringWithFormat:@"#%d", curQ+3];
				
				key = [NSString stringWithFormat:@"%d", curQ+=1];
				vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
				[self.OutputLines setObject:vals forKey:key];	
				
				a0 = @"SYS";
				a1 = @"#-1";
				a2 = @"#0";
				a3 = @"";
				
				key = [NSString stringWithFormat:@"%d", curQ+=1];
				vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
				[self.OutputLines setObject:vals forKey:key];	
				
				
				
				
			} else {	// char
				
			a0 = @"SYS"; 
			a1 = @"#-2";
			a2 = [NSString stringWithFormat:@"T%@",[[symLookup valueForKey:[[aT objectAtIndex:2] contents]] objectAtIndex:1]];
			a3 = @"";
			
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];	
			}
			
			
			return nil;
			
		case 26: // statement -> if (exp) statement
			
			x = [[ifStack pop] intValue] + 1; 
			key = [NSString stringWithFormat:@"%d", x];
			vals = [NSMutableArray arrayWithArray:[self.OutputLines objectForKey:key]];
			[vals replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"#%d", curQ+1]];
			[self.OutputLines setValue: vals forKey:key];
						
			return nil;
			
		case 27: //statement -> while (exp) do statement
			
			// gen JMP peek(whilestack)
			// backpatch (pop(evalstack), nextquad)
			y = [[whileStack peek] intValue] + 1;
			
			a0 = @"JMP"; // unconditional jump
			a1 = @"";
			a2 = @"";
			a3 = [NSString stringWithFormat:@"#%i", y-4];
			
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];	
			
			
			int x = [[whileStack pop] intValue] + 1; 
			key = [NSString stringWithFormat:@"%d", x];
			vals = [NSMutableArray arrayWithArray:[self.OutputLines objectForKey:key]];
			[vals replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"#%d", curQ+1]];
			[self.OutputLines setValue: vals forKey:key];
			
			
			return nil;
			
		case 28: // lhs -> ID '=' rhs
			
			newToken.type = [[lookup objectForKey:@"lhs"] intValue];
			
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			[tStack pop];
			bT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [aT contents];
			
			if ([symLookup valueForKey:[bT contents]] == nil)
				[NSException raise:@"Variable Error" format:@"Variable error line #%i: Tried to assign a value into ID %@ (which was never declared).", [bT line_number], [bT contents]];

			
			vals = [symLookup valueForKey:[bT contents]];
			
			//NSLog(@"RHS Type: %@, LHS ( %@ ) Type: %@", [aT value_type], [bT contents], [vals objectAtIndex:0]);
			
			if([aT value_type] != [vals objectAtIndex:0]) // possible type error?
			{
				if([[aT value_type] isEqualToString:@"STRING"] || [[vals objectAtIndex:0] isEqualToString:@"STRING"]) // definite type error
				{
					[NSException raise:@"Type Error" format:@"Type error line #%i: Tried to assign a something of type %@ to ID %@ (which is type: %@). Coersion failed.", [bT line_number], [aT value_type], [bT contents], [vals objectAtIndex:0]];
					return nil;
				}
				
				if([[aT value_type] isEqualToString:@"SHORT"])
				{
					
					
					vals2 = vals;
					
					a0 = @"JGT";
					if([[aT contents] characterAtIndex:0] == 'T') // hack hack hack: is a temp variable, drop the #
						a1 = [NSString stringWithFormat:@"%@", [aT contents]];
					else
						a1 = [NSString stringWithFormat:@"#%@", [aT contents]];					a2 = @"#32767";
					a3 = [NSString stringWithFormat:@"#%d", curQ+5];
					
					key = [NSString stringWithFormat:@"%d", curQ+=1];
					vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
					[self.OutputLines setObject:vals forKey:key];
					
					a0 = @"JLT";
					if([[aT contents] characterAtIndex:0] == 'T') // hack hack hack: is a temp variable, drop the #
						a1 = [NSString stringWithFormat:@"%@", [aT contents]];
					else
						a1 = [NSString stringWithFormat:@"#%@", [aT contents]];					a2 = @"#-32768";
					a3 = [NSString stringWithFormat:@"#%d", curQ+6];
					
					key = [NSString stringWithFormat:@"%d", curQ+=1];
					vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
					[self.OutputLines setObject:vals forKey:key];	
					
					a0 = @"STO";
					if([[aT contents] characterAtIndex:0] == 'T')
						a1 = [NSString stringWithFormat:@"%@", [aT contents]];
					else
						a1 = [NSString stringWithFormat:@"#%@", [aT contents]];
					
					a2 = @"";
					a3 = [NSString stringWithFormat:@"T%d", [[vals2 objectAtIndex:1] intValue]];
					
					key = [NSString stringWithFormat:@"%d", curQ+=1];
					vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
					[self.OutputLines setObject:vals forKey:key];	
					
					a0 = @"JMP";
					a1 = @"";
					a2 = @"";
					a3 = [NSString stringWithFormat:@"#%d", curQ+5];
					
					key = [NSString stringWithFormat:@"%d", curQ+=1];
					vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
					[self.OutputLines setObject:vals forKey:key];	
					
					a0 = @"STO";
					a1 = @"#32767";
					a2 = @"";
					a3 = [NSString stringWithFormat:@"T%d", [[vals2 objectAtIndex:1] intValue]];
					
					key = [NSString stringWithFormat:@"%d", curQ+=1];
					vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
					[self.OutputLines setObject:vals forKey:key];	
					
					a0 = @"JMP";
					a1 = @"";
					a2 = @"";
					a3 = [NSString stringWithFormat:@"#%d", curQ+3];
					
					key = [NSString stringWithFormat:@"%d", curQ+=1];
					vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
					[self.OutputLines setObject:vals forKey:key];	
				
					a0 = @"STO";
					a1 = @"#-32768";
					a2 = @"";
					a3 = [NSString stringWithFormat:@"T%d", [[vals2 objectAtIndex:1] intValue]];
					
					key = [NSString stringWithFormat:@"%d", curQ+=1];
					vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
					[self.OutputLines setObject:vals forKey:key];	
				
					return nil;
				}
				
				// else we're going to coerce both values to INTs and change the tokens appropriately
			}
			
			newToken.value_type = [bT value_type];
				

			if([[aT value_type] isEqualToString:@"STRING"] ) // todo: handle strings
				
			{
			
				[symStrings setValue:[aT contents] forKey:[bT contents]];
				
				
				return nil;
				
			} 
			
			a0 = @"STO";
			if([[aT contents] characterAtIndex:0] == 'T') // hack hack hack: is a temp variable, drop the #
				a1 = [NSString stringWithFormat:@"%@", [aT contents]];
			else
				a1 = [NSString stringWithFormat:@"#%@", [aT contents]];

			a2 = @"";
			a3 = [NSString stringWithFormat:@"T%d", [[vals objectAtIndex:1] intValue]];
			
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];	
			
			
			return [newToken retain];
			
		case 29: // rhs -> expression
		
			newToken.type = [[lookup objectForKey:@"rhs"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [aT contents];
			newToken.value_type = [aT value_type];
			return [newToken retain];
			
		case 30: // rhs -> LIT_STRING	
			newToken.type = [[lookup objectForKey:@"rhs"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [aT contents];
			newToken.value_type = @"STRING";
			//NSLog(@"New rhs value_type for %@ is %@", [newToken contents], [newToken value_type]);

			return [newToken retain];
						
		case 31: // rhs -> casting expression
			
			newToken.type = [[lookup objectForKey:@"rhs"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			bT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [aT contents];
			newToken.value_type = [bT value_type];
			return [newToken retain];
			
		case 32: // casting -> ( STANDARD_TYPE )
			
			newToken.type = [[lookup objectForKey:@"casting"] intValue];
			[tStack pop];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [aT contents];
			newToken.value_type = [aT value_type];
			return [newToken retain];
 			
			
		case 33: //  expression-> simple_exp
			
			newToken.type = [[lookup objectForKey:@"expression"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [aT contents];
			newToken.value_type = [aT value_type];
			return [newToken retain];
			
		case 34: // expression -> SIMPLE_EXP relop SIMPLE_EXP
			
			
			b = ((Token*)[[tStack pop]objectAtIndex:2]).contents;
			o = ((Token*)[[tStack pop]objectAtIndex:2]).contents;
			a = ((Token*)[[tStack pop]objectAtIndex:2]).contents;
			[tStack pop];
			id blah = [tStack pop];
			int sw = 0;
			if(blah != nil)
			sw = ((Token*)[blah objectAtIndex:2]).type;
			
			if([o isEqualToString:@">"])
				o = @"JGT";
			else if([o isEqualToString:@">="])
				o = @"JGE";
			else if([o isEqualToString:@"=="])
				o = @"JEQ";
			else if([o isEqualToString:@"<="])
				o = @"JLE";
			else if([o isEqualToString:@"<"])
				o = @"JLT";
			else if([o isEqualToString:@"<>"])
				o = @"JNE";
					
			a0 = o;
			if([a characterAtIndex:0] == 'T')
				a1 = a;
			else 
				a1 = [NSString stringWithFormat:@"#%@", a];
			
			if([b characterAtIndex:0] == 'T')
				a2 = b;
			else 
				a2 = [NSString stringWithFormat:@"#%@", b];
			
			a3 = [NSString stringWithFormat:@"#%d", curQ + 4];
	
			NSString* key = [NSString stringWithFormat:@"%d", curQ+=1];
			NSArray* vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];		

			a0 = @"STO";
			a1 = @"#0";
			a2 = @"";
			a3 = [NSString stringWithFormat:@"T%d", ++tempreg];
					
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];	
					
			a0 = @"JMP";
			a1 = @"";
			a2 = @"";
			a3 = [NSString stringWithFormat:@"#%d", curQ+3];
					
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];	
					
			a0 = @"STO";
			a1 = @"#1";
			a2 = @"";
			a3 = [NSString stringWithFormat:@"T%d", tempreg];
					
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];	
			
			// if in an if statement (look at stack)
			
			// GEN JNE T #0 ???
			// push a backpatch
			
			if(sw == 105) // while
			{
				[whileStack push:[NSNumber numberWithInt:curQ]];
				a0 = @"JNE";
				a1 = [NSString stringWithFormat:@"T%d", tempreg];
				a2 = @"#1";
				a3 = @"???";
				
				key = [NSString stringWithFormat:@"%d", curQ+=1];
				vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
				[self.OutputLines setObject:vals forKey:key];	
				
			} 
			
			if (sw == 106) // if
			{	
				[ifStack push:[NSNumber numberWithInt:curQ]];
				a0 = @"JNE";
				a1 = [NSString stringWithFormat:@"T%d", tempreg];
				a2 = @"#1";
				a3 = @"???";
				
				key = [NSString stringWithFormat:@"%d", curQ+=1];
				vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
				[self.OutputLines setObject:vals forKey:key];	
			} 
			
			// end if
			
			newToken.type = [[lookup objectForKey:@"expression"] intValue];
			newToken.contents = @"BOOLEAN";
			newToken.value_type = @"BOOLEAN";
			newToken.value = [NSNumber numberWithInt:tempreg];
			return [newToken retain];
		
		case 35: // simple_exp -> term
			newToken.type = [[lookup objectForKey:@"simple_exp"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [aT contents];
			newToken.value_type = [aT value_type];
			return [newToken retain];
			
		case 36: // simple_exp -> simple_exp addop term
			
			a2 = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			a0 = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			a1 = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			
			if([a2 characterAtIndex:0] != 'T') 
				a2 = [NSString stringWithFormat:@"#%@", a2];
			
			if([a1 characterAtIndex:0] != 'T') 
				a1 = [NSString stringWithFormat:@"#%@", a1];
			
			a3 = [NSString stringWithFormat:@"T%d", ++tempreg];
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];			
			
			newToken.type = [[lookup objectForKey:@"simple_exp"] intValue];
			newToken.contents = [a3 retain];
			newToken.value_type = @"NUMERIC";
			return [newToken retain];
		case 37: // term -> factor
			newToken.type = [[lookup objectForKey:@"term"] intValue];
			aT = [[[tStack pop] objectAtIndex:2] retain];
			newToken.contents = [aT contents];
			newToken.value_type = [aT value_type];

			return [newToken retain];

		case 38: // term -> term mulop factor
			
			a2 = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			a0 = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			a1 = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			
			if([a2 characterAtIndex:0] != 'T') 
				a2 = [NSString stringWithFormat:@"#%@", a2];
			
			if([a1 characterAtIndex:0] != 'T') 
				a1 = [NSString stringWithFormat:@"#%@", a1];
			
			a3 = [NSString stringWithFormat:@"T%d", ++tempreg];
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];			
			
			newToken.type = [[lookup objectForKey:@"term"] intValue];
			newToken.contents = [a3 retain];
			newToken.value_type = @"NUMERIC";
			return [newToken retain];
			
		case 39: // factor -> (ID)
			newToken.type = [[lookup objectForKey:@"factor"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [NSString stringWithFormat:@"T%@",[[symLookup valueForKey:[aT contents]] objectAtIndex:1]];
			newToken.value_type = [[symLookup valueForKey:[aT contents]] objectAtIndex:0];
			return [newToken retain];
			
			
		case 40: // factor -> (lit)
			newToken.type = [[lookup objectForKey:@"factor"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [aT contents];
			newToken.line_number = [aT line_number];
			newToken.value_type = @"NUMERIC";
			
			return [newToken retain];
		case 41:
			newToken.type = [[lookup objectForKey:@"factor"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = @"1";
			newToken.line_number = [aT line_number];
			newToken.value_type = @"NUMERIC";
			return [newToken retain];

		case 42:
			newToken.type = [[lookup objectForKey:@"factor"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = @"0";
			newToken.line_number = [aT line_number];
			newToken.value_type = @"NUMERIC";
			
			return [newToken retain];
			
		case 43: // factor -> not factor
			
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);

			a0 = @"NOT";
			a1 = [aT contents];
			a2 = @"";
			a3 = [aT contents];
			
			key = [NSString stringWithFormat:@"%d", curQ+=1];
			vals = [NSArray arrayWithObjects:a0, a1, a2, a3, nil];
			[self.OutputLines setObject:vals forKey:key];				
		
			newToken.type = [[lookup objectForKey:@"factor"] intValue];
			newToken.contents = [aT contents];
			newToken.line_number = [aT line_number];
			newToken.value_type = @"NUMERIC";
			
			return [newToken retain];
			
			
			
			
		case 44: // factor -> lit_char
			newToken.type = [[lookup objectForKey:@"factor"] intValue];
			aT = ((Token*)[[tStack pop] objectAtIndex:2]);
			newToken.contents = [NSString stringWithFormat:@"%i",[[aT contents] characterAtIndex:1]];
			newToken.line_number = [aT line_number];
			newToken.value_type = @"CHAR";
			
			return [newToken retain];			
			
		case 46: // relops
		case 47:
		case 48:
		case 49:
		case 50:
		case 51:
			newToken.type = [[lookup objectForKey:@"relop"] intValue];
			newToken.contents = ((Token*)[[tStack pop] objectAtIndex:2]).contents;
			return [newToken retain];			

			
			
		case 52: // addop -> + 
			newToken.type = [[lookup objectForKey:@"addop"] intValue];
			newToken.contents = @"ADD";
			return [newToken retain];
		case 53: // addop -> -
			newToken.type = [[lookup objectForKey:@"addop"] intValue];
			newToken.contents = @"SUB";
			return [newToken retain];
		case 54: // mulop -> * 
			newToken.type = [[lookup objectForKey:@"mulop"] intValue];
			newToken.contents = @"MUL";
			return [newToken retain];
		case 55: // mulop ->  / 
			newToken.type = [[lookup objectForKey:@"mulop"] intValue];
			newToken.contents = @"DIV";
			return [newToken retain];
		case 56: // mulop ->  %
			newToken.type = [[lookup objectForKey:@"mulop"] intValue];
			newToken.contents = @"MOD";
			return [newToken retain];
		default: return nil;

	}
		
}

static int comparePersonsUsingSelector(id p1, id p2, void *context)
{
	return [[NSNumber numberWithInt:[p1 intValue]] compare: [NSNumber numberWithInt:[p2 intValue]]];	
}
	
-(NSString*) stringValue
{
	NSString* Lines = @"";
	NSString* Key;
	NSMutableArray* Keys = [NSMutableArray arrayWithArray:[OutputLines allKeys]];
	[Keys sortUsingFunction:comparePersonsUsingSelector context:nil];
	for(Key in Keys)
	{
		NSArray* Val = [self.OutputLines objectForKey:Key];
		if(Key && Val)
		{
			Lines = [Lines stringByAppendingString:[NSString stringWithFormat:@"%i %@ %@,%@,%@\n", 
					[Key intValue], [Val objectAtIndex:0], [Val objectAtIndex:1], [Val objectAtIndex:2], [Val objectAtIndex:3] 
					]];
		}
	
	}

	Lines = [Lines stringByAppendingString:[NSString stringWithFormat:@"%i NOP ,,\n", (curQ+1)]];
	Lines = [Lines stringByAppendingString:[NSString stringWithFormat:@"%i NOP ,,\n", (curQ+2)]];
	Lines = [Lines stringByAppendingString:[NSString stringWithFormat:@"%i HLT ,,\n", (curQ+3)]];

	return [Lines retain];
}

@end
