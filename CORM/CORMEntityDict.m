//
//  CORMEntityDict.m
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityDict.h"

#import <objc/runtime.h>

@interface CORMEntityDict (Private)

- (void)_setKeys:(NSArray *)keys properties:(NSArray *)properties;

@end

@implementation CORMEntityDict

static NSArray * _keys = nil, * _properties = nil;

+ (NSArray *)mappedKeys
{
	return _keys;
}

+ (NSArray *)mappedNames
{
	return _properties;
}

@end

@implementation CORMEntityDict (Genesis)

+ (Class)entityDictClassWithName:(NSString *)name keys:(NSArray *)keys properties:(NSArray *)properties
{
	Class new = objc_allocateClassPair(self, [name cStringUsingEncoding:NSASCIIStringEncoding], 0);
	objc_registerClassPair(new);
	
	[new _setKeys:keys properties:properties];
	
	return new;
}

@end

@implementation CORMEntityDict (Private)

- (void)_setKeys:(NSArray *)keys properties:(NSArray *)properties
{
	_keys = keys;
	_properties = properties;
}

@end