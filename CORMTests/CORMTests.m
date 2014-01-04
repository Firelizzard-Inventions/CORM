//
//  CORMTests.m
//  CORMTests
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMTests.h"

// frameworks
#import <CORM/CORM.h>
#import <ORDA/ORDA.h>
#import <CocoaSQLite/CocoaSQLite.h>

@implementation CORMTests {
	NSAutoreleasePool * _pool;
}

static CORMStore * _store = nil;

+ (void)setUp
{
    [super setUp];
	
	@autoreleasepool {
		[CocoaSQLite register];
		
		NSString * path = [[NSBundle bundleForClass:[ORDA class]] pathForResource:@"Chinook_Sqlite" ofType:@"sqlite"];
		NSString * str = [NSString stringWithFormat:@"%@:%@", [CocoaSQLite scheme], [NSURL fileURLWithPath:path]];
		NSURL * URL = [NSURL URLWithString:str];
		
		id<ORDAGovernor> governor = [[ORDA sharedInstance] governorForURL:URL];
		if (governor.isError)
			return;
		
		_store = [[CORMStore alloc] initWithGovernor:governor];
		_store.generateClasses = YES;
		[CORM setDefaultStore:_store];
	}
}

+ (void)tearDown
{
	[_store release];
    
    [super tearDown];
}

- (void)setUp
{
	[super setUp];
	
	_pool = [[NSAutoreleasePool alloc] init];
	
	if (![CORM defaultStore])
		XCTFail(@"The default store is nil, cannot continue");
}

- (void)tearDown
{
	[_pool drain];
	
	[super tearDown];
}

@end
