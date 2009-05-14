//
//  preprocessor_tests.m
//  compiler
//
//  Created by Jeff Katz on Sunday 3/1/09.
//

#import "preprocessor_tests.h"


@implementation preprocessor_tests
const char* preProcessorTestInput = "\nPUBLIC STATIC VOID id ()\n{\n	VAR temp1 : INT;\n	VAR temp2 : STRING;\n	{		\n		\n		temp2 = \"Some String Literal\"; temp2 = \"Just kid(ding), this== is it\";\n		READ ( temp1 );\n		// READ ( temp2 ); <- this is bad, and commented\n		IF ( temp1 == 4 ) \n		\n		WHILE (temp1>=0)\n		{\n			\n			\n			temp1 = temp1-1; // subtract one here\n			WRITE ( temp1 );\n		}\n	}\n}\n$\n";

/*
 +(NSArray*) OpenFile:(const char*) filename;	// open a file into an array
 +(NSArray*) PreProcess:(NSArray*) lines;		// preprocess an array of lines into an array
 +(NSString *) processLine:(NSString*) line;		// preprocess one line 
 */

- (void) testProperTrimming
{	
	NSString* whatIhave = @"	jello  { ( ) }    ";
	NSString* whatIwant = @"jello { ( ) }";
	STAssertEqualObjects(whatIwant, [preprocessor processLine:whatIhave], @"Trimming done improperly!");
	whatIhave = @" // this entire line is a comment";
	whatIwant = @"";
	STAssertEqualObjects(whatIwant, [preprocessor processLine:whatIhave], @"Comment removal done improperly!");
	whatIhave = @"\t\t// // // // // this entire line is a comment";
	whatIwant = @"";
	STAssertEqualObjects(whatIwant, [preprocessor processLine:whatIhave], @"Comment removal done improperly!");
	whatIhave = @" \"This  is  a   \t   string literal \" ";
	whatIwant = @"\"This  is  a   \t   string literal \"";
	STAssertEqualObjects(whatIwant, [preprocessor processLine:whatIhave], @"Mangles string literals!");
	whatIhave = @" PUBLIC        STATIC       \t     VOID       ID ";
	whatIwant = @"PUBLIC STATIC VOID ID";
	STAssertEqualObjects(whatIwant, [preprocessor processLine:whatIhave], @"Doesn't remove spurrious whitespace!");
	whatIhave = @" \"This  is  a   \t   \\\"string\\\" literal \" ";
	whatIwant = @"\"This  is  a   \t   \\\"string\\\" literal \"";
	STAssertEqualObjects(whatIwant, [preprocessor processLine:whatIhave], @"Mangles escaped quotes in string literals!");
}

- (void) testBatch
{
	NSArray* whatIhave = [preprocessor PreProcess:[[NSString stringWithCString:preProcessorTestInput] componentsSeparatedByString:@"\n"]];
	NSArray* whatIwant = [NSArray arrayWithObjects: @"PUBLIC STATIC VOID id ()",@"{",@"VAR temp1 : INT;",@"VAR temp2 : STRING;",@"{",@"temp2 = \"Some String Literal\"; temp2 = \"Just kid(ding), this== is it\";",@"READ ( temp1 );",@"IF ( temp1 == 4 )",@"WHILE (temp1>=0)",@"{",@"temp1 = temp1-1;",@"WRITE ( temp1 );",@"}",@"}",@"}",@"$", nil];
	STAssertEqualObjects(whatIhave, whatIwant, @"Batch preprocessing failed");
}
@end
