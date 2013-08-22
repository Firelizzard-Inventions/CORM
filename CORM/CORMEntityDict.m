//
//  CORMEntityDict.m
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityDict.h"

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
	_data[key] = value;
}

- (NSString *)description
{
	NSArray * foreignKeys = [[self class] mappedForeignKeyClassNames];
	NSMutableArray * props = [NSMutableArray array];
	for (NSString * prop in _data) {
		if (![foreignKeys containsObject:prop.firstLetterUppercaseString])
			[props addObject:[NSString stringWithFormat:@"[%@]='%@'", prop, [self valueForKey:prop]]];
	}
	
	return [NSString stringWithFormat:@"<%s: %@>", class_getName([self class]), [props componentsJoinedByString:@", "]];
}

@end

@implementation CORMEntityDict (Genesis)

+ (Class)entityDictClassWithName:(NSString *)name andKeys:(NSArray *)keys andProperties:(NSArray *)properties andForeignKeys:(NSArray *)foreign
{
	Class new = objc_allocateClassPair(self, [name cStringUsingEncoding:NSASCIIStringEncoding], 0);
	objc_registerClassPair(new);
	
	[(NSObject *)new setAssociatedObject:keys forSelector:@selector(mappedKeys) withAssociationPolicy:OBJC_ASSOCIATION_RETAIN];
	[(NSObject *)new setAssociatedObject:properties forSelector:@selector(mappedNames) withAssociationPolicy:OBJC_ASSOCIATION_RETAIN];
	[(NSObject *)new setAssociatedObject:foreign forSelector:@selector(mappedForeignKeyClassNames) withAssociationPolicy:OBJC_ASSOCIATION_RETAIN];
	
	return new;
}

- (id)initWithKey:(id)key dictionary:(NSDictionary *)dict
{
	if (!(self = [super initWithKey:key dictionary:dict]))
		return nil;
	
	_data = @{}.mutableCopy;
	
	return self;
}

- (void)dealloc
{
	[_data release];
	
	[super dealloc];
}

@end