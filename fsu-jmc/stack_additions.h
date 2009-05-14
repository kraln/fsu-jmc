//
//  stack_additions.h
//  compiler
//
//  Created by Jeff Katz on Sunday 3/1/09.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (GWStack)
- (void)push:(id)inObject;
- (id)pop;
- (id)peek;

- (NSArray*)reverse;

@end

