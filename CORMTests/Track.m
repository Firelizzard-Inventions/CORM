//
//  Track.m
//  CORM
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "Track.h"

#import "Album.h"

@implementation Track

+ (BOOL)propertyNamesAreCaseSensitive
{
	return NO;
}

+ (NSArray *)mappedForeignKeyClassNames
{
	return @[@"Album"];
}

@end
