//
//  CORMEntityProxy.m
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMEntityProxy.h"

#import "CORMKey.h"
#import "CORMFactory.h"
#import "CORMFactory+Private.h"

#pragma clang diagnostic ignored "-Wprotocol"
@implementation CORMEntityProxy {
	id<CORMEntity> _entity;
}

+ (CORMEntityProxy *)entityProxyWithKey:(CORMKey *)key forFactory:(CORMFactory *)factory
{
	return [[[self alloc] initWithKey:key forFactory:factory] autorelease];
}

- (id)initWithKey:(CORMKey *)key forFactory:(CORMFactory *)factory
{
//	if (!(self = [super init]))
//		return nil;
	
	if (!key)
		key = [CORMKey key];
	
	if (!factory)
		return nil;
	
	_key = key.retain;
	_factory = factory.retain;
	_entity = nil;
	
	return self;
}

- (void)dealloc
{
	[_key release];
	[_factory release];
	
	[super dealloc];
}

- (id)entity
{
	if (!_entity)
		_entity = [self.factory entityForKey:self.key];
	
	return _entity;
}

- (NSString *)description
{
	if (!self.entity)
		return [super description];
	
	return [self.entity description];
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