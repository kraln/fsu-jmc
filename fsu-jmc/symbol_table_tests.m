//
//  symbol_table_tests.m
//  compiler
//

/*

 This class runs automated unit tests on the symbol table class, 
 and as an extension, the symbol_bucket class.
 
*/

#import "symbol_table_tests.h"
#import "symbol_table.h"
#import "symbol_bucket.h"


@implementation symbol_table_tests

@synthesize testTable;

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

- (void) testNewTableInstantiation
{	
	STAssertEquals([testTable name], @"Test Table", @"Symbol Table does not have assigned name!");
	STAssertEquals([testTable count], 0, @"New Symbol Table is not empty!");	
}

- (void) testAddOneBucket
{
	symbol_bucket* tempBucket = [[symbol_bucket alloc] initWithName:@"Sym1"];
	tempBucket._id = 1;
	tempBucket.datatype = D_INTEGER;
	tempBucket.value = [NSNumber numberWithInt:42];
	
	STAssertEquals([tempBucket name], @"Sym1", @"Bucket has wrong name or name not initialized properly");

	[testTable addBucket:tempBucket];
	STAssertEquals([testTable count], 1, @"Symbol Table has wrong number of elements!");	
	STAssertTrue([testTable isBucketInTable:@"Sym1"], @"Symbol table does not contain newly added bucket!");
	
	symbol_bucket* tempBucket2 = [testTable getBucketWithName:@"Sym1"];
	STAssertEquals([tempBucket2 name], @"Sym1", @"Retrieved Bucket has wrong name!");
	STAssertEquals([tempBucket2 _id], 1, @"Retrieved Bucket has wrong id!");
	STAssertEquals([tempBucket2 datatype], D_INTEGER, @"Retrieved Bucket has datatype");
	STAssertEquals([[tempBucket2 value] intValue], 42, @"Retrieved Bucket has wrong value!");

	[tempBucket release];
	[tempBucket2 release];
}

- (void) testAddThenRemove 
{
	symbol_bucket* tempBucket = [[symbol_bucket alloc] initWithName:@"Sym1"];
	tempBucket._id = 1;
	tempBucket.datatype = D_INTEGER;
	tempBucket.value = [NSNumber numberWithInt:42];
	
	[testTable addBucket:tempBucket];
	[testTable removeBucket:@"Sym1"];
	
	STAssertEquals([testTable count], 0, @"Symbol table is not empty!");
	STAssertFalse([testTable isBucketInTable:@"Sym1"], @"Symbol table says it still contains bucket!");
	symbol_bucket* tempBucket2 = [testTable getBucketWithName:@"Sym1"];
	STAssertTrue(tempBucket2 == nil, @"Retrieved object is not nil!");
	
}

- (void) testAddMultipleBuckets
{
	symbol_bucket* tempBucket = [[symbol_bucket alloc] initWithName:@"Sym1"];
	tempBucket._id = 1;
	tempBucket.datatype = D_INTEGER;
	tempBucket.value = [NSNumber numberWithInt:42];
	
	symbol_bucket* tempBucket2 = [[symbol_bucket alloc] initWithName:@"Sym2"];
	tempBucket2._id = 2;
	tempBucket2.datatype = D_STRING;
	tempBucket2.value = @"Test Symbol 2";
	
	symbol_bucket* tempBucket3 = [[symbol_bucket alloc] initWithName:@"Sym3"];
	tempBucket3._id = 3;
	tempBucket3.datatype = D_ETC;
	tempBucket3.value = [NSArray arrayWithObjects:@"One", @"Two", @"Three", nil];
	
	
	[testTable addBucket:tempBucket];
	STAssertEquals([testTable count], 1, @"Symbol Table has wrong number of elements!");	
	STAssertTrue([testTable isBucketInTable:@"Sym1"], @"Symbol table does not contain newly added bucket!");
	
	[testTable addBucket:tempBucket2];
	STAssertEquals([testTable count], 2, @"Symbol Table has wrong number of elements!");	
	STAssertTrue([testTable isBucketInTable:@"Sym2"], @"Symbol table does not contain newly added bucket!");
	
	[testTable addBucket:tempBucket3];
	STAssertEquals([testTable count], 3, @"Symbol Table has wrong number of elements!");	
	STAssertTrue([testTable isBucketInTable:@"Sym3"], @"Symbol table does not contain newly added bucket!");
	
	[testTable addBucket:tempBucket];
	STAssertEquals([testTable count], 3, @"Symbol Table has wrong number of elements!");	
	
	
}

- (void) testUpdateBucket 
{
	symbol_bucket* tempBucket = [[symbol_bucket alloc] initWithName:@"Sym1"];
	tempBucket._id = 1;
	tempBucket.datatype = D_INTEGER;
	tempBucket.value = [NSNumber numberWithInt:42];
	
	[testTable addBucket:tempBucket];

	tempBucket = [[symbol_bucket alloc] initWithName:@"Sym1"];
	tempBucket._id = 1;
	tempBucket.datatype = D_INTEGER;
	tempBucket.value = [NSNumber numberWithInt:24];

	[testTable setBucket:tempBucket]; // change the number from 42 to 24
	STAssertEquals([testTable count], 1, @"Symbol Table has wrong number of elements!");	
	symbol_bucket* tempBucket2 = [testTable getBucketWithName:@"Sym1"];
	STAssertEquals([[tempBucket2 value] intValue], 24, @"Retrieved Bucket has wrong value!");

}

- (void) setUp
{
	 testTable = [[symbol_table alloc] initWithName:@"Test Table"];
}

- (void) tearDown
{
	[testTable release];
    // Release data structures here.
}
@end
