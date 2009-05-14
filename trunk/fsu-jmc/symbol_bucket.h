//
//  symbol_bucket.h
//  compiler
//
//  Created by Jeff Katz on Thursday 2/5/09.
//

#import <Cocoa/Cocoa.h>

enum DATATYPES { D_INTEGER, D_STRING, D_ETC };

@interface symbol_bucket : NSObject {

	int _id;
	NSString * name; // the lexeme
	enum DATATYPES datatype; 
	id value; // what is contained in the variable
	// int scope; // not used because we have a different table for each scope
	
}

@property (nonatomic, assign) int _id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, assign) enum DATATYPES datatype;
@property (nonatomic, retain) id value;

-(id) initWithName: (NSString *) Name;
@end
