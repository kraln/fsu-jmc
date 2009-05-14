//
//  symbol_table.h
//  compiler
//
//  pages 85-91
//  keeps track of information about identifiers 
//

#import <Cocoa/Cocoa.h>
#import "symbol_bucket.h"

@interface symbol_table : NSObject {
	NSMutableDictionary * _table;
	NSString * name;
}

@property (nonatomic, retain) NSMutableDictionary* _table;
@property (nonatomic, retain) NSString * name;
-(int) count;
-(id) initWithName: (NSString *) _name;
-(void) addBucket: (symbol_bucket*) bucket;
-(void) setBucket: (symbol_bucket*) bucket;
-(void) removeBucket: (NSString *) name;
-(BOOL) isBucketInTable: (NSString *) name;
-(symbol_bucket*) getBucketWithName: (NSString*) name;

@end
