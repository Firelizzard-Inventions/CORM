//
//  CORMEntityProxy.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityProxy.h"

#import "CORMKey.h"
#import "CORMFactory.h"

@implementation CORMEntityProxy {
	CORMEntity * _entity;
}

+ (instancetype)entityProxyWithKey:(id)key forFactory:(CORMFactory *)factory
{
	return [[[self alloc] initWithKey:key forFactory:factory] autorelease];
}

- (id)initWithKey:(id)key forFactory:(CORMFactory *)factory
{
	//	if (!(self = [super init]))
	//		return nil;
	
	if (!factory)
		return nil;
	
	_key = [CORMKey keyWithObject:key].retain;
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
