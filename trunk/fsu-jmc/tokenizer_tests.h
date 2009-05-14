//
//  tokenizer_tests.h
//  compiler
//
//  Created by Jeff Katz on Sunday 3/1/09.
//

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import "tokenizer.h"

@interface tokenizer_tests : SenTestCase {
	tokenizer* myTokenizer; 
}

@property (nonatomic, retain) tokenizer* myTokenizer;

@end
