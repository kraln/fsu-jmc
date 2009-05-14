//
//  symbol_table.m
//  compiler
//

#import "symbol_table.h"
#import "symbol_bucket.h"

@implementation symbol_table
@synthesize _table, name;

-(id) init {
	
    if ( self = [super init] ) {
		_table = [[NSMutableDictionary alloc] init];
    }
	
    return self;
}

-(id) initWithName: (NSString *) _name
{
	self = [self init];
	self.name = _name;
	
	return self;
}

-(void) addBucket: (symbol_bucket*) bucket
{
	/*
	 add an object to the table referenced by name
	 does not add object if it already exists
	 */
	if(![self isBucketInTable:[bucket name]])
		[_table setObject: bucket forKey: [bucket name]];

}

-(void) setBucket: (symbol_bucket*) bucket
{
	/*
	updates an existing object, only if it already exists.
	 */
	if([self isBucketInTable:[bucket name]])
	[_table setObject: bucket forKey: [bucket name]];
	
}

-(int) count
{
	/*
	 returns the count of buckets
	 */
	return [_table count];
	
}

-(void) removeBucket: (NSString *) name
{
	/* remove object */
	
	[_table removeObjectForKey: name];
}

-(BOOL) isBucketInTable: (NSString *) name
{
	/* 
	 does table contain bucket with this name?
	 */
	return [[_table allKeys] containsObject:name];
}

-(symbol_bucket*) getBucketWithName: (NSString*) name
{
	/*
	 retrieve object stored in table
	 */
	return [_table objectForKey: name];
}


@end
