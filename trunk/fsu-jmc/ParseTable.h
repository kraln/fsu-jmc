/*
 *  ParseTable.h
 *  compiler
 *
 *  Created by Jeff Katz on Tuesday 4/7/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

@interface ParseTable : NSObject { 
	NSDictionary* reduceTable; 
	NSDictionary* stateTable; // nsdictionary of curstate -> dictionary (which is symbol -> action) 
}

@property (nonatomic, retain) NSDictionary* stateTable;
@property (nonatomic, retain) NSDictionary* reduceTable;

@end