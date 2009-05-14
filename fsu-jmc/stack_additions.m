//
//  stack_additions.m
//  compiler
//
//  Created by Jeff Katz on Tuesday 4/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@implementation NSMutableArray (GWStack)

- (void)push:(id)inObject
{
	if(inObject) [self addObject:inObject];
}

- (id)peek
{
	return [self lastObject];	
}

- (id)pop
{
	id theResult = nil;
	if([self count])
	{
		theResult = [[[self lastObject] retain] autorelease];
		[self removeLastObject];
	}
	return theResult;
}

- (NSArray*)reverse {
	if([self count] == 0)
		return self;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
		
        i++;
        j--;
    }
	return self;
}

@end
