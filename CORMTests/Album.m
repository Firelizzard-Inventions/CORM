//
//  Album.m
//  CORM
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "Album.h"

@implementation Album

+ (BOOL)propertyNamesAreCaseSensitive
{
	return NO;
}

+ (NSArray *)mappedForeignKeyClassNames
{
	return @[@"Artist"];
}

+ (NSArray *)referencingClassNames
{
	return @[@"Track"];
}

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	_tracks = [NSArray array];
	
	return self;
}

@end
