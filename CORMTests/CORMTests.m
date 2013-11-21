//
//  CORMTests.m
//  CORMTests
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMTests.h"

#import <TypeExtensions/TypeExtensions.h>
#import <CORM/CORM.h>
#import <CORM/CORMStore.h>
#import <ORDA/ORDA.h>
#import <ORDASQLite/ORDASQLite.h>

#import "CORMEntityImpl.h"
#import "CORMEntityProxy.h"
#import "CORMEntityDict.h"

#import "Track.h"
#import "Album.h"

@implementation CORMTests

static CORMStore * store = nil;
static NSAutoreleasePool * pool = nil;

+ (void)setUp
{
    [super setUp];
	
	pool = [[NSAutoreleasePool alloc] init];
	
	[ORDASQLite register];
    
	NSString * path = [[NSBundle bundleForClass:[ORDA class]] pathForResource:@"Chinook_Sqlite" ofType:@"sqlite"];
	NSString * str = [NSString stringWithFormat:@"%@:%@", [ORDASQLite scheme], [NSURL fileURLWithPath:path]];
	NSURL * URL = [NSURL URLWithString:str];
	
	id<ORDAGovernor> governor = [[ORDA sharedInstance] governorForURL:URL];
	if (governor.isError)
		return;
	
	store = [[CORMStore alloc] initWithGovernor:governor];
	store.generateClasses = YES;
	[CORM setDefaultStore:store];
}

+ (void)tearDown
{
	[store release];
	
	[pool drain];
    
    [super tearDown];
}

- (void)setUp
{
	[super setUp];
	
	if (![CORM defaultStore])
		STFail(@"The default store is nil, cannot continue");
}

- (void)testBinding
{
	id data = @{@"GenreId" : @(1), @"Name" : @"Rock"}.mutableCopy;
	
	Class Genre = [store generateClassForName:@"Genre"];
	if (!Genre)
		STFail(@"Failed to create class");
	
	id<CORMEntity> entity = [[Genre alloc] initByBindingTo:data];
	if (!entity)
		STFail(@"Failed to create entity");
	
	data[@"GenreId"] = @(2);
	if (![@(2) isEqual:[(NSObject *)entity valueForKey:@"GenreId"]])
		STFail(@"Bindings failure: altering source did not alter entity");
	
	[data release];
	
	[(NSObject *)entity setValue:@"NotRock" forKey:@"Name"];
	if (![@"NotRock" isEqual:data[@"Name"]])
		STFail(@"Bindings failure: altering entity did not alter source");
	
	[entity release];
}

- (void)testEntityDict
{
	Class Genre = [store generateClassForName:@"Genre"];
	if (!Genre)
		STFail(@"Failed to create Genre subclass of CORMEntityDict");
	
	id<CORMEntity> genre = [Genre entityForKey:@(1)];
	if (!genre)
		STFail(@"Failed to create Genre (Dict) entity for key 1");
	
	if (![@(1) isEqual:[(NSObject *)genre valueForKey:@"GenreId"]] || ![@"Rock" isEqual:[(NSObject *)genre valueForKey:@"Name"]])
		STFail(@"Retreived object had bad values");
}

- (void)testEntityForKey
{
	Track * track = [Track entityForKey:@"1"];
	if (!track)
		STFail(@"Failed to create Track entity for key 1");
}

- (void)testForeignKeys
{
	Track * track = [Track entityForKey:@(3)];
	
	if (!track)
		STFail(@"Failed to create entities");
	
	if (!track.album)
		STFail(@"Failed to retreive track -> album");
	
	if (!track.album.artist)
		STFail(@"Failed to retreive track -> album -> artist");
	
	if (!track.genre)
		STFail(@"Failed to retreive track -> genre");
	
	if (!track.mediaType)
		STFail(@"Failed to retreive track -> mediaType");
}

- (void)testNonRedundancyAndProxies
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

@end
