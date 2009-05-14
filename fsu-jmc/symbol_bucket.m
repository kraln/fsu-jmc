//
//  symbol_bucket.m
//  compiler
//

#import "symbol_bucket.h"


@implementation symbol_bucket
@synthesize _id, name, value, datatype;

-(id) init 
{
	if (self = [super init])
	{
		self.name = @"Unnamed";
		self._id = -1;
	}
	
	return self;
}

-(id) initWithName: (NSString *) Name
{
	if (self = [super init])
	{
		self.name = Name;
		self._id = -1;
	}
	
	return self;	
}


@end
