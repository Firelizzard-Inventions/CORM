//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityImpl.h"

#import "CORMEntityImpl_private.h"
#import "CORMFactory.h"
#import "CORMStore.h"

#import <objc/runtime.h>


@implementation CORMEntityImpl

static CORMFactory * _defaultFactory = nil;

+ (CORMFactory *)registerWithStore:(CORMStore *)store
{
	return [store registerFactoryForType:self];
}

+ (CORMFactory *)setDefaultStore:(CORMStore *)store
{
	CORMFactory * factory = [self registerWithStore:store];
	[self setDefaultFactory:factory];
	return factory;
}

+ (CORMFactory *)defaultFactory
{
	return _defaultFactory;
}

+ (void)setDefaultFactory:(CORMFactory *)newFactory
{
	if (_defaultFactory == newFactory)
		return;
	
	[_defaultFactory release];
	_defaultFactory = [newFactory retain];
}

#pragma mark - Genesis

- (id)initWithKey:(id)key
{
	return [self initWithKey:key dictionary:@{}];
}

- (id)initWithKey:(id)key dictionary:(NSDictionary *)dict
{
	if (!(self = [super init]))
		return nil;
	
	// type extensions, WTF?
//	if ([self isMemberOfClass:[CORMEntity class]])
//		[self _subclassImplementationExceptionFromMethod:_cmd isClassMethod:NO];
	
	if (!dict)
		return self;
	
	if (!dict.count)
		return self;
	
	[self setValuesForKeysWithDictionary:dict];
	
	return self;
}

+ (CORMEntityImpl *)entityWithKey:(id)key
{
	return [[[self alloc] initWithKey:key] autorelease];
}

+ (CORMEntityImpl *)entityWithKey:(id)key dictionary:(NSDictionary *)dict
{
	return [[[self alloc] initWithKey:key] autorelease];
}

#pragma mark - Mapping

+ (NSString *)mappedClassName
{
	return [NSString stringWithCString:class_getName(self) encoding:NSASCIIStringEncoding];
}

+ (NSArray *)mappedKeys
{
	static NSArray * keys = nil;
	
	if (!keys) {
		NSString * className = [self mappedClassName].lowercaseString;
		
		NSString * keyID = @"id";
		NSString * keyEntityID = [NSString stringWithFormat:@"%@%@", className, keyID];
		NSString * keyEntity_ID = [NSString stringWithFormat:@"%@_%@", className, keyID];
		
		for (NSString * name in [self mappedNames]) {
			name = name.lowercaseString;
			
			if ([name isEqualToString:keyID] ||
				[name isEqualToString:keyEntityID] ||
				[name isEqualToString:keyEntity_ID])
				keys = @[name].retain;
		}
	}
	
	if (!keys)
		[NSException raise:kCORMEntityBadKeysException format:@"Could not find sutable ID field to be key, please override"];
	
	return keys;
}

+ (NSArray *)mappedNames
{
	static NSArray * names = nil;
	
	if (!names) {
		unsigned int count;
		objc_property_t * properties = class_copyPropertyList(self, &count);
		
		NSMutableArray * _names = [NSMutableArray arrayWithCapacity:count];
		for (int i = 0; i < count; i++)
			_names[i] = [NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding];
		
		free(properties);
		
		names = _names.copy;
	}
	
	return names;
}

+ (NSArray *)mappedForeignKeyClassNames
{
	return @[];
}

+ (NSString *)mappedNameForPropertyName:(NSString *)propName
{
	if (![[self mappedNames] containsObject:propName])
		return nil;
	
	return propName;
}

+ (NSString *)propertyNameForMappedName:(NSString *)mappedName
{
	if (![[self mappedNames] containsObject:mappedName])
		return nil;
	
	return mappedName;
}

+ (NSString *)classNameForForeignKeyPropertyNames:(NSArray *)propNames
{
	return nil;
}

+ (NSArray *)propertyNameForForeignKeyClassName:(NSString *)className
{
	return nil;
}

@end