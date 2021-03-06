//
//  CORMTests.m
//  CORMTests
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMTests.h"

// frameworks
#import <XCTest/XCTest.h>
#import <TypeExtensions/TypeExtensions.h>
#import <CORM/CORM.h>
#import <CORM/CORMEntitySynth.h>
#import <ORDA/ORDA.h>
#import <CocoaSQLite/CocoaSQLite.h>

// private CORM classes
#import "CORMEntityProxy.h"

// test classes
#import "Track.h"
#import "Album.h"

@interface CORMFeatureTests : CORMTests

@end

@implementation CORMFeatureTests

- (void)testBinding
{
	id data = @{@"GenreId" : @(1), @"Name" : @"Rock"}.mutableCopy;
	
	Class Genre = [CORMEntitySynth synthesizeClassForNameWithDefaultStore:@"Genre"];
	if (!Genre)
		XCTFail(@"Failed to create class");
	
	CORMEntitySynth * entity = [Genre entity];
	if (!entity)
		XCTFail(@"Failed to create entity");
	
	[entity bindTo:data withOptions:kCORMEntityBindingOptionSetReceiverFromObject];
	
	data[@"GenreId"] = @(2);
	if (![@(2) isEqual:[(NSObject *)entity valueForKey:@"GenreId"]])
		XCTFail(@"Bindings failure: altering source did not alter entity");
	
	[data release];
	
	[(NSObject *)entity setValue:@"NotRock" forKey:@"Name"];
	if (![@"NotRock" isEqual:data[@"Name"]])
		XCTFail(@"Bindings failure: altering entity did not alter source");
}

- (void)testEntityDict
{
	Class Genre = [CORMEntitySynth synthesizeClassForNameWithDefaultStore:@"Genre"];
	if (!Genre)
		XCTFail(@"Failed to create Genre subclass of CORMEntityDict");
	
	CORMEntity * genre = [Genre entityForKey:@(1)];
	if (!genre)
		XCTFail(@"Failed to create Genre (Dict) entity for key 1");
	
	if (![@(1) isEqual:[(NSObject *)genre valueForKey:@"GenreId"]] || ![@"Rock" isEqual:[(NSObject *)genre valueForKey:@"Name"]])
		XCTFail(@"Retreived object had bad values");
}

- (void)testEntityForKey
{
	Track * track = [Track entityForKey:@"1"];
	if (!track)
		XCTFail(@"Failed to create Track entity for key 1");
}

- (void)testForeignKeys
{
	Track * track = [Track entityForKey:@(3)];
	
	if (!track)
		XCTFail(@"Failed to create entities");
	
	if (!track.album.description)
		XCTFail(@"Failed to retreive track -> album");
	
	if (!track.album.artist.description)
		XCTFail(@"Failed to retreive track -> album -> artist");
	
	if (!track.genre.description)
		XCTFail(@"Failed to retreive track -> genre");
	
	if (!track.mediaType.description)
		XCTFail(@"Failed to retreive track -> mediaType");
}

- (void)testNonRedundancyAndProxies
{
	Track * track1 = [Track entityForKey:@(2)];
	Track * track2 = [Track entityForKey:@(2)];
	Album * album = [Album entityForKey:@(2)];
	
	if (!track1 || !track2 || !album)
		XCTFail(@"Failed to create entities");
	
	if (track1 != track2)
		XCTFail(@"Entities for same key are not identical");
	
	Album * t1album = track1.album;
	if ([t1album.class isSubclassOfClass:CORMEntityProxy.class])
		t1album = (Album *)((CORMEntityProxy *)t1album).entity;
	
	if (t1album != album)
		XCTFail(@"Entities for same key are not identical");
}

- (void)testRowNonpersistance
{
	NSDictionary * rows;
	object_getInstanceVariable([[CORM defaultStore].governor createTable:@"Track"], "_rows", (void **)&rows);
	
	if (rows[@(10)])
		XCTFail(@"Can't run test, dictionary already contains value");
	
	Track * track;
	@autoreleasepool {
		track = [Track entityForKey:@(10)];
		if (!track)
			XCTFail(@"Failed to create Track entity for key 10");
		
		if (!rows[@(10)])
			XCTFail(@"Result object is not in dictionary");
	}
	
	if (rows[@(10)])
		XCTFail(@"Row value has not been released");
}

- (void)testReferencingCollections
{
	Album * album = [Album entityForKey:@(1)];
	
	if (![album valueForKeyPath:@"tracks.@count"])
		XCTFail(@"Album tracks not retreived");
	
	if (![album.tracks[0] isKindOfClass:Track.class])
		XCTFail(@"Album tracks are not tracks");
}

@end
