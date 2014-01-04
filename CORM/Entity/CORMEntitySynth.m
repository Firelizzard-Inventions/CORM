//
//  CORMEntitySynth.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntitySynth.h"

#import <TypeExtensions/TypeExtensions.h>
#import <ORDA/ORDA.h>

#import "CORMDefaults.h"
#import "CORMEntityBase+Private.h"
#import "CORMFactory.h"
#import "CORMStore.h"

@implementation CORMEntitySynth {
	NSMutableDictionary * _data;
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
	[_data autorelease];
	
	[super dealloc];
}

- (NSString *)description
{
	NSMutableArray * props = [NSMutableArray array];
	for (NSString * prop in _data) {
		if (![self.class stringIsMappedForeignKeyClassName:[self.class classNameForForeignKeyPropertyName:prop]])
			[props addObject:[NSString stringWithFormat:@"[%@]='%@'", prop, [self valueForKey:prop]]];
	}
	
	return [NSString stringWithFormat:@"<%@: %@>", [self className], [props componentsJoinedByString:@", "]];
}

- (id)valueForKey:(NSString *)key
{
	return _data[key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	[self willChangeValueForKey:key];
	
	if (value)
		_data[key] = value;
	else
		[_data removeObjectForKey:key];
	
	[self didChangeValueForKey:key];
}

- (void)setNilValueForKey:(NSString *)key
{
	[self setValue:nil forKey:key];
}

@end

@implementation CORMEntitySynth (Generation)

id associatedObjectForSelector(id self, SEL _cmd) {
	return [(NSObject *)self associatedObjectForSelector:_cmd];
}

+ (Class)synthesizeClassForNameWithDefaultStore:(NSString *)className
{
	return [self synthesizeClassForName:className withStore:[CORM defaultStore]];
}

+ (Class)synthesizeClassForName:(NSString *)className withStore:(CORMStore *)store
{
	Class aClass = NSClassFromString(className);
	if (aClass) {
		if ([aClass isSubclassOfClass:CORMEntity.class])
			return aClass;
		else
			return nil;
	}
	
	if (!store.generateClasses)
		return nil;
	
	id<ORDATable> table = [store.governor createTable:className];
	if (table.isError)
		return nil;
	
	NSArray * keys = [table primaryKeyNames];
	NSArray * columns = [table columnNames];
	NSArray * foreign = [table foreignKeyTableNames];
	
	aClass = objc_allocateClassPair(self, [className cStringUsingEncoding:NSASCIIStringEncoding], 0);
	
	Class aClassClass = object_getClass(aClass);
	class_addMethod(aClassClass, @selector(mappedKeys),                 (IMP)&associatedObjectForSelector, "@@:");
	class_addMethod(aClassClass, @selector(mappedNames),                (IMP)&associatedObjectForSelector, "@@:");
	class_addMethod(aClassClass, @selector(mappedForeignKeyClassNames), (IMP)&associatedObjectForSelector, "@@:");
	
	objc_registerClassPair(aClass);
	
	[(NSObject *)aClass setAssociatedObject:keys    forSelector:@selector(mappedKeys)];
	[(NSObject *)aClass setAssociatedObject:columns forSelector:@selector(mappedNames)];
	[(NSObject *)aClass setAssociatedObject:foreign forSelector:@selector(mappedForeignKeyClassNames)];
	
	return aClass;
}

@end