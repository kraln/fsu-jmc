//
//  tokenizer_tests.m
//  compiler
//
//  Created by Jeff Katz on Sunday 3/1/09.
//

#import "tokenizer_tests.h"


@implementation tokenizer_tests
@synthesize myTokenizer;
const char* tokenizerTestInput = "\nPUBLIC STATIC VOID id ()\n{\n	VAR temp1 : INT;\n	VAR temp2 : STRING;\n	{		\n		\n		temp2 = \"Some String Literal\"; temp2 = \"Just kid(ding), this== is it\";\n		READ ( temp1 );\n		// READ ( temp2 ); <- this is bad, and commented\n		IF ( temp1 == 4 ) \n		\n		WHILE (temp1>=0)\n		{\n			\n			\n			temp1 = temp1-1; // subtract one here\n			WRITE ( temp1 );\n		}\n	}\n}\n$\n";

/*
 STAssertNotNil(a1, description, ...)
 STAssertTrue(expression, description, ...)
 STAssertFalse(expression, description, ...)
 STAssertEqualObjects(a1, a2, description, ...)
 STAssertEquals(a1, a2, description, ...)
 STAssertThrows(expression, description, ...)
 STAssertNoThrow(expression, description, ...)
 STFail(description, ...)
 
 */

@end
