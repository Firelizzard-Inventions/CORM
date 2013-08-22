//
//  CORMTests.m
//  CORMTests
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMTests.h"

#import <CORM/CORM.h>
#import <CORM/CORMStore.h>
#import <ORDA/ORDA.h>
#import <ORDA/ORDASQLite.h>

#import "CORMEntityImpl.h"
#import "CORMEntityProxy.h"
#import "CORMEntityDict.h"

#import "Track.h"
#import "Album.h"

@implementation CORMTests {
	CORMStore * store;
}

- (void)setUp
{
    [super setUp];
	
	[ORDASQLite register];
    
	NSString * path = [[NSBundle bundleForClass:[ORDA class]] pathForResource:@"Chinook_Sqlite" ofType:@"sqlite"];
	NSString * str = [NSString stringWithFormat:@"%@:%@", [ORDASQLite scheme], [NSURL fileURLWithPath:path]];
	NSURL * URL = [NSURL URLWithString:str];
	
	id<ORDAGovernor> governor = [[ORDA sharedInstance] governorForURL:URL];
	if (governor.isError)
		STFail(@"Governor error");
	
	store = [[CORMStore alloc] initWithGovernor:governor];
	[CORM setDefaultStore:store];
	
	// This shouldn't be necessary
	[CORMEntityImpl registerWithStore:store];
	[CORMEntityDict registerWithStore:store];
	[Track registerWithStore:store];
	[Album registerWithStore:store];
}

- (void)tearDown
{
	[store release];
    
    [super tearDown];
}

- (void)testEntityForKey
{
	Track * track = [Track entityForKey:@"1"];
	if (!track)
		STFail(@"Failed to create Track entity for key 1");
	
	NSLog(@"%@", track);
}

- (void)testEntityDict
{
	BOOL old = store.generateClasses;
	store.generateClasses = YES;
	Class Genre = [store generateClassForName:@"Genre"];
	if (!Genre)
		STFail(@"Failed to create Genre subclass of CORMEntityDict");
	store.generateClasses = old;
	
	id<CORMEntity> genre = [Genre entityForKey:@(1)];
	if (!genre)
		STFail(@"Failed to create Genre (Dict) entity for key 1");
	
	NSLog(@"%@", genre);
}

- (void)testSomething
{
	Track * track1 = [Track entityForKey:@(1)];
	Track * track2 = [Track entityForKey:@(1)];
	Album * album = [Album entityForKey:@(1)];
	if (!track1 || !track2 || !album)
		STFail(@"Failed to create entities");
	
	if (track1 != track2)
		STFail(@"Entities for same key are not identical");
	
	if (((CORMEntityProxy *)track1.album).entity != album)
		STFail(@"Entities for same key are not identical");
}

@end
