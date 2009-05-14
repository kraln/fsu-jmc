//
//  tokenizer.m
//  compiler
//
//  Created by Jeff Katz on Sunday 3/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "tokenizer.h"
#import "utility.h"
#import "Token.h"

@implementation tokenizer
@synthesize RawTokenStack, TokenStack, ReservedWords,Tokens;

-(id) init 
{
	if (self = [super init])
	{
		self.ReservedWords = [NSDictionary dictionaryWithDictionary:[tokenizer InitReservedWords]];
		self.TokenStack = [[NSMutableArray alloc] init];
		self.RawTokenStack = [[NSMutableArray alloc] init];
		self.Tokens = [NSDictionary dictionaryWithDictionary:[tokenizer InitTokens]];
	}
	
	return self;
}

+(NSString*) padString:(NSString*) what
{
	// make tokenizing a heck of a lot easier.
	what = [what stringByReplacingOccurrencesOfString:@"{" withString:@" { "];
	what = [what stringByReplacingOccurrencesOfString:@"}" withString:@" } "];
	what = [what stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
	what = [what stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
	what = [what stringByReplacingOccurrencesOfString:@"[" withString:@" [ "];
	what = [what stringByReplacingOccurrencesOfString:@"]" withString:@" ] "];
	what = [what stringByReplacingOccurrencesOfString:@":" withString:@" : "];
	what = [what stringByReplacingOccurrencesOfString:@";" withString:@" ; "];
	what = [what stringByReplacingOccurrencesOfString:@"+" withString:@" + "];
	what = [what stringByReplacingOccurrencesOfString:@"-" withString:@" - "];
	what = [what stringByReplacingOccurrencesOfString:@"/" withString:@" / "];
	what = [what stringByReplacingOccurrencesOfString:@"*" withString:@" * "];
	what = [what stringByReplacingOccurrencesOfString:@"%" withString:@" % "];
	what = [what stringByReplacingOccurrencesOfString:@"<=" withString:@" ≤ "]; // this should
	what = [what stringByReplacingOccurrencesOfString:@">=" withString:@" ≥ "]; // take care of
	what = [what stringByReplacingOccurrencesOfString:@"==" withString:@" ≡ "]; // any funny business
	what = [what stringByReplacingOccurrencesOfString:@"<>" withString:@" ≠ "]; // with double-relops
	what = [what stringByReplacingOccurrencesOfString:@">" withString:@" > "];
	what = [what stringByReplacingOccurrencesOfString:@"<" withString:@" < "];
	what = [what stringByReplacingOccurrencesOfString:@"=" withString:@" = "];
	what = [what stringByReplacingOccurrencesOfString:@"," withString:@" , "];

	return [what retain];
}

-(void)addTokensFromString:(NSString*) source whichWasLineNumber:(int) linenum
{
	NSString* temp = [[NSString alloc] init];
	source = [source stringByReplacingOccurrencesOfString:@"\\\"" withString:@"ﾞ"]; // handle escaped quotes
	source = [source stringByReplacingOccurrencesOfString:@"\\n" withString:@"␤"]; // newlines
	NSScanner* scan = [NSScanner scannerWithString:source];
	NSCharacterSet *stopSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
	[scan setCharactersToBeSkipped:[NSCharacterSet newlineCharacterSet]];
	
	[scan scanUpToCharactersFromSet:stopSet intoString:&temp]; // scan up to any string literals 
	NSMutableArray* chunks = [[tokenizer padString:temp] componentsSeparatedByString:@" "];	// chop into bits
	while(![scan isAtEnd])
	{
		// if we get here, we're at the start of a(nother) string literal
		// I'm not quite sure it's legal to have two on one line, but it might be.
		[scan setScanLocation:[scan scanLocation] + 1];
		[scan scanUpToCharactersFromSet:stopSet intoString:&temp];
		temp = [NSString stringWithFormat:@"\"%@\"", temp];
		[chunks addObject:temp]; // definitely don't pad a string literal out
		// read the whole thing into a token
		[scan setScanLocation:[scan scanLocation] + 1];
		// try and read to the end of the line
		[scan scanUpToCharactersFromSet:stopSet intoString:&temp];		
		[chunks addObjectsFromArray: [[tokenizer padString:temp] componentsSeparatedByString:@" "]];
	}
	
	
	
	NSString *tmp;
	NSEnumerator *nse = [chunks objectEnumerator];
	NSDictionary * myTokDic = [NSDictionary dictionaryWithDictionary:[tokenizer InitTokens]];

	while(tmp = [nse nextObject]) {
		if (![tmp isEqualToString:@""])
		{
			// change back single-character tokens to their full representations
			// NOTE: this will only affect unicode string-literals, and only these five characters.
			// if this is undesirable, it can be worked around. 
			tmp = [tmp stringByReplacingOccurrencesOfString:@"≤" withString:@"<="];
			tmp = [tmp stringByReplacingOccurrencesOfString:@"≥" withString:@">="];
			tmp = [tmp stringByReplacingOccurrencesOfString:@"≡" withString:@"=="];
			tmp = [tmp stringByReplacingOccurrencesOfString:@"≠" withString:@"<>"];
			tmp = [tmp stringByReplacingOccurrencesOfString:@"ﾞ" withString:@"\""]; // handle escaped quotes
			
			Token* t = [[Token alloc] init];
			t.contents = tmp;
			t.line_number = linenum;
			t.value = nil;
			
			NSNumber* token_val = [myTokDic valueForKey:tmp];
			
			if(token_val)
			{
				int which_token = [token_val intValue];
				if ((which_token != 777) && ((which_token < 100) || (which_token > 300))) // nonterminal and not $end
					t.type = 999; // must be an ID...
				//todo:  should we add to symbol table here? 
				else
					t.type = which_token; // otherwise, it's a terminal, so set it.
			} else { // must be a string, char, or num
				char first = [tmp characterAtIndex:0];
				switch (first)
				{
					case '\"':
						t.type = [[myTokDic valueForKey:@"LIT_STRING"] intValue];					
						break;
					case '\'':
						t.type = [[myTokDic valueForKey:@"LIT_CHAR"] intValue];
						break;
					case '0':
					case '1':
					case '2':
					case '3':
					case '4':
					case '5':
					case '6':
					case '7':
					case '8':
					case '9':	
						t.type = [[myTokDic valueForKey:@"LIT_NUM"] intValue];
						break;
						
					default: // invalid token					
						t.type = 999;
						//[utility terrible_error:[NSString stringWithFormat:@"Invalid token encountered while tokenizing. Token Contents: %@", tmp] where:@"Tokenizer"];
						//return;
				}
				
				
			}
			
			[self.TokenStack push:t];
			[self.RawTokenStack push: tmp];
		}
	}
	
	
	
}

+(NSMutableDictionary*) InitReservedWords
{
	NSMutableDictionary* temp = [[NSMutableDictionary alloc] init];
	
	[temp setObject:@"" forKey:@"STATIC"];
	[temp setObject:@"" forKey:@"VOID"];
	[temp setObject:@"" forKey:@"PUBLIC"];
	[temp setObject:@"" forKey:@"PRIVATE"];
	[temp setObject:@"" forKey:@"VAR"];
	[temp setObject:@"" forKey:@"STRING"];
	[temp setObject:@"" forKey:@"CHAR"];
	[temp setObject:@"" forKey:@"BOOLEAN"];
	[temp setObject:@"" forKey:@"INT"];
	[temp setObject:@"" forKey:@"NEW"];
	[temp setObject:@"" forKey:@"READ"];
	[temp setObject:@"" forKey:@"WRITE"];
	[temp setObject:@"" forKey:@"IF"];
	[temp setObject:@"" forKey:@"WHILE"];
	[temp setObject:@"" forKey:@"DO"];
	[temp setObject:@"" forKey:@"TRUE"];
	[temp setObject:@"" forKey:@"FALSE"];
	[temp setObject:@"" forKey:@"NOT"];
	[temp setObject:@"" forKey:@"SHORT"];
	[temp setObject:@"" forKey:@"<>"];
	[temp setObject:@"" forKey:@"=="];
	[temp setObject:@"" forKey:@"<="];	
	[temp setObject:@"" forKey:@">="];
	[temp setObject:@"" forKey:@"}"];
	[temp setObject:@"" forKey:@"{"];
	[temp setObject:@"" forKey:@"]"];
	[temp setObject:@"" forKey:@"["];
	[temp setObject:@"" forKey:@">"];
	[temp setObject:@"" forKey:@"<"];
	[temp setObject:@"" forKey:@"="];
	[temp setObject:@"" forKey:@";"];
	[temp setObject:@"" forKey:@":"];
	[temp setObject:@"" forKey:@"/"];
	[temp setObject:@"" forKey:@"-"];
	[temp setObject:@"" forKey:@","];
	[temp setObject:@"" forKey:@"+"];
	[temp setObject:@"" forKey:@"*"];
	[temp setObject:@"" forKey:@")"];
	[temp setObject:@"" forKey:@"("];
	[temp setObject:@"" forKey:@"'"];
	[temp setObject:@"" forKey:@"%"];
	[temp setObject:@"" forKey:@"$"];
				
	return temp;
	
}

+(NSString*) getKeyForNum:(int) num
{
	NSMutableDictionary* temp = [self InitTokens];
	for(NSString* key in temp.allKeys)
	{
	if([[temp valueForKey:key] intValue] == num)
		return key;
		
	}
	
	return @"No such token!";
	
}
		
+(NSMutableDictionary*) InitTokens
{
	NSMutableDictionary* temp = [[NSMutableDictionary alloc] init];
	
	/* nonterminal */
	[temp setValue:[NSNumber numberWithInt:50] forKey:@"$accept"];
	[temp setValue:[NSNumber numberWithInt:51] forKey:@"start"];
	[temp setValue:[NSNumber numberWithInt:52] forKey:@"access"];
	[temp setValue:[NSNumber numberWithInt:53] forKey:@"identifier_list"];
	[temp setValue:[NSNumber numberWithInt:54] forKey:@"declarations"];
	[temp setValue:[NSNumber numberWithInt:55] forKey:@"type"];
	[temp setValue:[NSNumber numberWithInt:56] forKey:@"standard_type"];
	[temp setValue:[NSNumber numberWithInt:57] forKey:@"compound_stmt"];
	[temp setValue:[NSNumber numberWithInt:58] forKey:@"optional_stmts"];
	[temp setValue:[NSNumber numberWithInt:59] forKey:@"object"];
	[temp setValue:[NSNumber numberWithInt:60] forKey:@"statement_list"];
	[temp setValue:[NSNumber numberWithInt:61] forKey:@"statement"];	
	[temp setValue:[NSNumber numberWithInt:62] forKey:@"lhs"];
	[temp setValue:[NSNumber numberWithInt:63] forKey:@"rhs"];
	[temp setValue:[NSNumber numberWithInt:64] forKey:@"casting"];
	[temp setValue:[NSNumber numberWithInt:65] forKey:@"expression"];
	[temp setValue:[NSNumber numberWithInt:66] forKey:@"simple_exp"];
	[temp setValue:[NSNumber numberWithInt:67] forKey:@"term"];
	[temp setValue:[NSNumber numberWithInt:68] forKey:@"factor"];
	[temp setValue:[NSNumber numberWithInt:69] forKey:@"size"];
	[temp setValue:[NSNumber numberWithInt:70] forKey:@"relop"];
	[temp setValue:[NSNumber numberWithInt:71] forKey:@"addop"];
	[temp setValue:[NSNumber numberWithInt:72] forKey:@"mulop"];
	
	/* terminal, reserved words */
	[temp setValue:[NSNumber numberWithInt:100] forKey:@"SHORT"];
	[temp setValue:[NSNumber numberWithInt:101] forKey:@"NOT"];
	[temp setValue:[NSNumber numberWithInt:102] forKey:@"FALSE"];
	[temp setValue:[NSNumber numberWithInt:103] forKey:@"TRUE"];
	[temp setValue:[NSNumber numberWithInt:104] forKey:@"DO"];
	[temp setValue:[NSNumber numberWithInt:105] forKey:@"WHILE"];
	[temp setValue:[NSNumber numberWithInt:106] forKey:@"IF"];
	[temp setValue:[NSNumber numberWithInt:107] forKey:@"WRITE"];
	[temp setValue:[NSNumber numberWithInt:108] forKey:@"READ"];
	[temp setValue:[NSNumber numberWithInt:109] forKey:@"NEW"];
	[temp setValue:[NSNumber numberWithInt:110] forKey:@"INT"];
	[temp setValue:[NSNumber numberWithInt:111] forKey:@"BOOLEAN"];
	[temp setValue:[NSNumber numberWithInt:112] forKey:@"CHAR"];
	[temp setValue:[NSNumber numberWithInt:113] forKey:@"STRING"];
	[temp setValue:[NSNumber numberWithInt:114] forKey:@"VAR"];
	[temp setValue:[NSNumber numberWithInt:115] forKey:@"PRIVATE"];
	[temp setValue:[NSNumber numberWithInt:116] forKey:@"PUBLIC"];
	[temp setValue:[NSNumber numberWithInt:117] forKey:@"VOID"];
	[temp setValue:[NSNumber numberWithInt:118] forKey:@"STATIC"];

	/* terminal, relops and such */
	[temp setValue:[NSNumber numberWithInt:200] forKey:@"REL_NEQ"];
	[temp setValue:[NSNumber numberWithInt:200] forKey:@"<>"];
	[temp setValue:[NSNumber numberWithInt:201] forKey:@"REL_EQ"];
	[temp setValue:[NSNumber numberWithInt:201] forKey:@"=="];
	[temp setValue:[NSNumber numberWithInt:202] forKey:@"REL_LTE"];
	[temp setValue:[NSNumber numberWithInt:202] forKey:@"<="];	
	[temp setValue:[NSNumber numberWithInt:203] forKey:@"REL_GTE"];
	[temp setValue:[NSNumber numberWithInt:203] forKey:@">="];
	[temp setValue:[NSNumber numberWithInt:204] forKey:@"LIT_CHAR"];
	[temp setValue:[NSNumber numberWithInt:205] forKey:@"LIT_STRING"];
	[temp setValue:[NSNumber numberWithInt:206] forKey:@"LIT_NUM"];
	[temp setValue:[NSNumber numberWithInt:207] forKey:@"}"];
	[temp setValue:[NSNumber numberWithInt:208] forKey:@"{"];
	[temp setValue:[NSNumber numberWithInt:209] forKey:@"]"];
	[temp setValue:[NSNumber numberWithInt:210] forKey:@"["];
	[temp setValue:[NSNumber numberWithInt:211] forKey:@">"];
	[temp setValue:[NSNumber numberWithInt:212] forKey:@"<"];
	[temp setValue:[NSNumber numberWithInt:213] forKey:@"="];
	[temp setValue:[NSNumber numberWithInt:214] forKey:@";"];
	[temp setValue:[NSNumber numberWithInt:215] forKey:@":"];
	[temp setValue:[NSNumber numberWithInt:216] forKey:@"/"];
	[temp setValue:[NSNumber numberWithInt:217] forKey:@"-"];
	[temp setValue:[NSNumber numberWithInt:218] forKey:@","];
	[temp setValue:[NSNumber numberWithInt:219] forKey:@"+"];
	[temp setValue:[NSNumber numberWithInt:220] forKey:@"*"];
	[temp setValue:[NSNumber numberWithInt:221] forKey:@")"];
	[temp setValue:[NSNumber numberWithInt:222] forKey:@"("];
	[temp setValue:[NSNumber numberWithInt:224] forKey:@"%"];
	
	
	/* special */
	[temp setValue:[NSNumber numberWithInt:999] forKey:@"ID"];
	[temp setValue:[NSNumber numberWithInt:888] forKey:@"$default"];
	[temp setValue:[NSNumber numberWithInt:777] forKey:@"$"];
	[temp setValue:[NSNumber numberWithInt:666] forKey:@"error"];
		 
	return temp;
			
		}
		



@end
