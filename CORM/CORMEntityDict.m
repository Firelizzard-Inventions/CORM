//
//  CORMEntityDict.m
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMEntityDict.h"

#import "CORMEntityImpl+Private.h"

#import <objc/runtime.h>
#import <TypeExtensions/NSObject+associatedObjectForSelector.h>
#import <TypeExtensions/NSString+firstLetterCaseString.h>

@implementation CORMEntityDict {
	NSMutableDictionary * _data;
}

+ (NSArray *)mappedKeys
{
	return [(NSObject *)self associatedObjectForSelector:_cmd];
}

+ (NSArray *)mappedNames
{
	return [(NSObject *)self associatedObjectForSelector:_cmd];
}

+ (NSArray *)mappedForeignKeyClassNames
{
	return [(NSObject *)self associatedObjectForSelector:_cmd];
}

- (id)valueForKey:(NSString *)key
{
	return _data[key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if (value)
		_data[key] = value;
	else {
		[self willChangeValueForKey:key];
		[_data removeObjectForKey:key];
		[self didChangeValueForKey:key];
	}
}

- (NSString *)description
{
	NSArray * foreignKeys = [[self class] mappedForeignKeyClassNames];
	NSMutableArray * props = [NSMutableArray array];
	for (NSString * prop in _data) {
		if (![foreignKeys containsObject:prop.firstLetterUppercaseString])
			[props addObject:[NSString stringWithFormat:@"[%@]='%@'", prop, [self valueForKey:prop]]];
	}
	
	return [NSString stringWithFormat:@"<%@: %@>", [self className], [props componentsJoinedByString:@", "]];
}

- (void)setNilValueForKey:(NSString *)key
{
	[self setValue:nil forKey:key];
}

@end

@implementation CORMEntityDict (Genesis)

+ (Class)entityDictClassWithName:(NSString *)name andKeys:(NSArray *)keys andProperties:(NSArray *)properties andForeignKeys:(NSArray *)foreign
{
	Class new = objc_allocateClassPair(self, [name cStringUsingEncoding:NSASCIIStringEncoding], 0);
	objc_registerClassPair(new);
	
	[(NSObject *)new setAssociatedObject:keys forSelector:@selector(mappedKeys)];
	[(NSObject *)new setAssociatedObject:properties forSelector:@selector(mappedNames)];
	[(NSObject *)new setAssociatedObject:foreign forSelector:@selector(mappedForeignKeyClassNames)];
	
	return new;
}

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	_data = @{}.mutableCopy;
	
	return self;
}

- (void)dealloc
{
	[self invalidate];
	
	[_data release];
	
	[super dealloc];
}

@end