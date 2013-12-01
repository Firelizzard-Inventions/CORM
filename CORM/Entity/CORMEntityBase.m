//
//  CORMEntityBase.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityBase+Private.h"

#import <objc/runtime.h>

@implementation CORMEntityBase {
	CORMKey * _key;
	NSMutableArray * _bound;
}

+ (BOOL)propertyNamesAreCaseSensitive
{
	return YES;
}

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	if (self.class == CORMEntity.class)
		@throw [NSException exceptionWithName:@"Abstract class instantiation" reason:@"CORMEntityBase cannot be directly instantiated - it is an abstract class of a class cluster" userInfo:nil];
	
	_key = nil;
	_bound = [NSMutableArray array].retain;
	
	return self;
}

- (void)invalidate
{
	if (!self.valid)
		return;
	
	for (_BoundObjectData * obj in _bound) {
		for (NSString * name in obj.names)
			[obj.object removeObserver:obj.proxy forKeyPath:name context:nil];
		for (NSString * mappedName in [self.class mappedNames])
			[self removeObserver:self forKeyPath:[self.class propertyNameForMappedName:mappedName] context:nil];
	}
	[_bound release];
	_bound = nil;
	
	[super invalidate];
}

- (CORMKey *)key
{
	if (_key)
		goto _return;
	
	NSMutableArray * elems = [NSMutableArray array];
	
	for (NSString * mappedKey in [self.class mappedKeys])
		[elems addObject:[self valueForKey:[self.class propertyNameForMappedName:mappedKey]]];
	
	//	_key = [[CORMKeyImpl alloc] initWithArray:elems];
	
_return:
	return _key;
}

- (void)clearKey
{
	[_key release];
	_key = nil;
}

@end