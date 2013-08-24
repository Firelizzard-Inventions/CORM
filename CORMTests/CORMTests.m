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

@implementation CORMTests

static CORMStore * store = nil;

+ (void)setUp
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
	store.generateClasses = YES;
	[CORM setDefaultStore:store];
}

+ (void)tearDown
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
	Class Genre = [store generateClassForName:@"Genre"];
	if (!Genre)
		STFail(@"Failed to create Genre subclass of CORMEntityDict");
	
	id<CORMEntity> genre = [Genre entityForKey:@(1)];
	if (!genre)
		STFail(@"Failed to create Genre (Dict) entity for key 1");
	
	NSLog(@"%@", genre);
}

- (void)testSomething
{
	Track * track1 = [Track entityForKey:@(2)];
	Track * track2 = [Track entityForKey:@(2)];
	Album * album = [Album entityForKey:@(2)];
	if (!track1 || !track2 || !album)
		STFail(@"Failed to create entities");
	
	if (track1 != track2)
		STFail(@"Entities for same key are not identical");
	
	Album * t1album = track1.album;
	if ([t1album.class isSubclassOfClass:CORMEntityProxy.class])
		t1album = (Album *)((CORMEntityProxy *)t1album).entity;
	
	if (t1album != album)
		STFail(@"Entities for same key are not identical");
}

- (void)testSomeMoreStuff
{
	Track * track = [Track entityForKey:@(3)];
	if (!track)
		STFail(@"Failed to create entities");
	
	NSLog(@"%@", track);
	NSLog(@"%@", track.album);
	NSLog(@"%@", track.album.artist);
	NSLog(@"%@", track.genre);
	NSLog(@"%@", track.mediaType);
}

@end
