//
//  CORMTests.m
//  CORMTests
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMTests.h"
#import <CORM/CORM.h>

@interface CORMRegressionTests : CORMTests

@end

@implementation CORMRegressionTests {
	CORMKey *k1, *k2;
}

- (void)setUp
{
	[super setUp];
	
	k1 = [CORMKey keyWithObject:@"asdf"];
	k2 = [CORMKey keyWithObject:@"asdf"];
}

- (void)testHash
{
	if (k1.hash != k2.hash)
		XCTFail(@"Identical keys must have identical hashes");
}

- (void)testEquals
{
	if (![k1 isEqual:k2])
		XCTFail(@"-[NSObject isEqual:] must return true for identical keys");
}

@end
