//
//  CORMEntityProxy.m
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityProxy.h"

#import "CORMKey.h"
#import "CORMFactory.h"
#import "CORMFactory_private.h"

@implementation CORMEntityProxy

- (id)initWithKey:(CORMKey *)key forFactory:(CORMFactory *)factory
{
//	if (!(self = [super init]))
//		return nil;
	
	if (!key)
		key = [CORMKey key];
	
	if (!factory)
		return nil;
	
	_key = key;
	_factory = factory;
	
	return self;
}

- (id)entity
{
	static CORMEntityImpl * _entity = nil;
	
	if (!_entity)
		_entity = [self.factory _entityForKey:self.key];
	
	return _entity;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
	if (!self.entity)
		return [super methodSignatureForSelector:sel];
	
	return [self.entity methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
	if (!self.entity)
		return [super forwardInvocation:invocation];
	
	[invocation invokeWithTarget:self.entity];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if (!self.entity)
		return NO;
	
	return [self.entity respondsToSelector:aSelector];
}

@end