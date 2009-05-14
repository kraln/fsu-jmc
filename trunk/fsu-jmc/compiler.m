#import <Foundation/Foundation.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#import "preprocessor.h"
#import <time.h>
#import "tokenizer.h"
#import "Parser.h"
#import "stack_additions.h"
#import "utility.h"
#include <sys/time.h>
#import "CodeGeneration.h"

void usage(char* wat)
{
	
	[utility setDebug:YES	andVerbose:YES];
	 [utility debug:[NSString stringWithFormat:@"JMC Usage: %s -dv12345 <inputfile> <outputfile>", wat]];
	 return;
}

int main (int argc, char * const argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	struct timeval tv, tv2; 
	gettimeofday(&tv, NULL);
	
	int debug = 0;   // enable debug mode
	int verbose = 0; // verbose debug mode
	int flag_1 = 0;  // stop after internal setup
	int flag_2 = 0;  // stop after preprocessing
	int flag_3 = 0;  // stop after tokenizing
	int flag_4 = 0;  // stop after parsing
	int flag_5 = 0;  // stop after intermediate generation
	int flag_6 = 0;  // stop after optimization
	int flag_7 = 0;  // stop after code generation
	char* infile = NULL;
	char* outfile = NULL; 
	
	int c;	
	while ((c = getopt (argc, argv, "dv12345")) != -1)
		switch (c)
	{
		case 'd':
			debug = 1;
			break;
		case 'v':
			verbose = 1;
			break;
		case '1':
			flag_1 = 1;
			break;
		case '2':
			flag_2 = 1;
			break;
		case '3':
			flag_3 = 1;
			break;
		case '4':
			flag_4 = 1;
			break;
		case '5':
			flag_5 = 1;
			break;
		case '?':
			if (isprint (optopt))
				fprintf (stderr, "Unknown option `-%c'.\n", optopt);
			else
				fprintf (stderr,
						 "Unknown option character `\\x%x'.\n",
						 optopt);
			return -1;
		default:
			usage(argv[0]);
			return -1;
			//abort ();
	}
	[utility setDebug: debug andVerbose:verbose];
	
	int index = optind;
	
	if (index + 1 < argc)
		outfile = argv[index+1];
	else
		outfile = NULL;
	
	if (index < argc)
		infile = argv[index];
	else
	{
		usage(argv[0]);
		return -1;
	}
	[utility debug:[NSString stringWithFormat:@"-=- Jeff's M++ Compiler (JMC)"]];	
	[utility debug:[NSString stringWithFormat:@"->- Options: Debug: %d, Verbose: %d, MaskFlags:%d%d%d%d%d%d%d", debug, verbose, flag_1,flag_2,flag_3,flag_4,flag_5,flag_6,flag_7]];

	[utility verbose:[NSString stringWithFormat:@"->- Compiling %s to %s", infile, outfile]];
	
	[utility verbose:[NSString stringWithFormat:@"- -"]];
	[utility debug:[NSString stringWithFormat:@"-1- Internal Setup"]];
	if(flag_1) return 1;
	
	// generate or load reserved word list, allocate memory, etc. 
	
	[utility verbose:[NSString stringWithFormat:@"- -"]];
	[utility debug:[NSString stringWithFormat:@"-2- Preprocessing"]];
	// Preprocess
		// Strip Whitespace
		// Expand Macros
	NSArray* input = [preprocessor OpenFile: infile];
	[utility verbose:[NSString stringWithFormat:@"->- Cleansed %d lines", [input count]]];
	NSArray* processed = [preprocessor PreProcess:input];
	
		// processed will contain some nils. this is to keep line numbers even.
	
	if(flag_2) return 2;

	[utility verbose:[NSString stringWithFormat:@"- -"]];
	[utility debug:[NSString stringWithFormat:@"-3- Tokenizing/Scanning"]];
	// Tokenizer / scanner	
	
	tokenizer* myTokenizer = [[tokenizer alloc] init];
	NSString *tmp;
	NSEnumerator *nse = [processed objectEnumerator];
	int lnum = 0;
	while(tmp = [nse nextObject]) {
		lnum++;
		if(![tmp isEqualToString:@""])
			[myTokenizer addTokensFromString: tmp whichWasLineNumber:lnum];
	}
	
	[utility verbose:[NSString stringWithFormat:@"->- Got %i tokens from %i lines", [myTokenizer.TokenStack count], [processed count]]];

	if( [myTokenizer.TokenStack count] == 0)
	{
		[utility debug:[NSString stringWithFormat:@"-X- Scanning failed: Got no tokens. Does the file exist?"]];
		return -1;
	}
	if(flag_3) return 3;

	[utility verbose:[NSString stringWithFormat:@"- -"]];
	[utility debug:[NSString stringWithFormat:@"-4- Parsing / Intermediate Language Generation"]];
	// Parser		-- Syntactical Analysis
	// Also Code Generation
	Parser* myParser = [[Parser alloc] initWithTokens:myTokenizer.TokenStack];
	CodeGeneration* cg = [myParser parse];
	
	if(!myParser.Accept)
	{
		[utility setDebug:YES andVerbose:YES];
		[utility debug:[NSString stringWithFormat:@"-X- Parsing failed: %@", myParser.error]];
		return -1;
	}

	[utility verbose:[NSString stringWithFormat:@"->- Parsed successfully!"]];
	[utility verbose:[NSString stringWithFormat:@"->- Generated %i instructions", [[[cg stringValue] componentsSeparatedByString:@"\n"] count]]];
		if(flag_4) return 4;

	[utility verbose:[NSString stringWithFormat:@"- -"]];

	@try {
		
		if(!flag_5)[[cg stringValue] writeToFile:[NSString stringWithFormat:@"%s",outfile] atomically:YES];
	}
	@catch (NSException* exception) 
	{
		
		[utility setDebug:YES andVerbose:YES];
		[utility debug:[NSString stringWithFormat:@"-X- Writing failed: %@", [exception reason]]];
		return -1;

	}
	
	[utility verbose:[NSString stringWithFormat:@"->- Wrote output file \"%s\" successfully!", outfile]];

	
	gettimeofday(&tv2, NULL);
	float ffps = (abs(tv2.tv_usec - tv.tv_usec)/1000000.0f);
	
	[utility debug:[NSString stringWithFormat:@"-=- Compilation Completed (time: %fs)", ffps]];	
	
    [pool drain];
    return 0;
}
