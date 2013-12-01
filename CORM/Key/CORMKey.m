//
//  CORMKey.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMKey+Private.h"

#import "CORMEntity.h"
#import "CORMKeyRowid.h"
#import "CORMKeyDescriptor.h"
#import "CORMKeyArray.h"
#import "CORMKeyDictionary.h"

@implementation CORMKey

+ (instancetype)key
{
	return [self keyWithNil];
}

+ (instancetype)keyWithNil
{
	return nil;
}

#pragma mark -

+ (instancetype)keyWithRowid:(NSNumber *)rowid
{
	return [CORMKeyRowid keyWithRowid:rowid];
}

+ (instancetype)keyWithDescriptor:(NSString *)string
{
	return [CORMKeyDescriptor keyWithDescriptor:string];
}

+ (instancetype)keyWithArray:(NSArray *)arr
{
	return [CORMKeyArray keyWithArray:arr];
}

+ (instancetype)keyWithDictionary:(NSDictionary *)dict
{
	return [CORMKeyDictionary keyWithDictionary:dict];
}

#pragma mark -

+ (instancetype)keyWithObject:(id)obj
{
	if (!obj)
		return [self keyWithNil];
	
	if ([obj isKindOfClass:CORMKey.class])
		return obj;
	
	if ([obj isKindOfClass:[NSString class]])
		return [self keyWithDescriptor:obj];
	
	if ([obj isKindOfClass:[NSArray class]])
		return [self keyWithArray:obj];
	
	return [self keyWithArray:@[obj]];
}

+ (instancetype)keyWithObjects:(id)obj, ...
{
	NSMutableArray * arr = [NSMutableArray array];
	
	va_list ap;
	va_start(ap, obj);
	for (; obj; obj = va_arg(ap, id))
		[arr addObject:obj];
	va_end(ap);
	
	return [self keyWithArray:arr];
}

+ (instancetype)keyWithObjects:(const void *)objs count:(NSUInteger)count
{
	return [self keyWithArray:[NSArray arrayWithObjects:objs count:count]];
}

+ (instancetype)keyWithObject:(id)obj forProperty:(NSString *)prop
{
	return [self keyWithDictionary:[NSDictionary dictionaryWithObject:obj forKey:prop]];
}

+ (instancetype)keyWithObjects:(NSArray *)objs forProperties:(NSArray *)props
{
	return [self keyWithDictionary:[NSDictionary dictionaryWithObjects:objs forKeys:props]];
}

+ (instancetype)keyWithObjectsAndProperties:(id)obj, ...
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	va_list ap;
	va_start(ap, obj);
	for (id prop = nil; obj; obj = va_arg(ap, id)) {
		prop = va_arg(ap, id);
		
		if (!prop)
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"varargs must be object, propertyName pairs" userInfo:nil];
		
		dict[prop] = obj;
	}
	va_end(ap);
	
	return [self keyWithDictionary:dict];
}

+ (instancetype)keyWithKey:(CORMKey *)key forEntityType:(Class<CORMMapping>)type
{
	return [self keyWithObjects:key.values forProperties:[type mappedKeys]];
}

+ (instancetype)keyWithData:(id)data forEntityType:(Class<CORMMapping>)type
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	if ([data respondsToSelector:@selector(allKeys)])
		for (NSString * name in [data allKeys]) {
			id value = [data valueForKey:name];
			if (value)
				dict[[type mappedNameForPropertyName:name]] = value;
		}
	else
		for (NSString * name in [type mappedNames]) {
			id value = [data valueForKey:name];
			if (value)
				dict[name] = value;
		}
	
	return [self keyWithDictionary:dict];
}

+ (instancetype)keyWithObjects:(NSArray *)objs forEntityType:(Class<CORMMapping>)type
{
	return [self keyWithObjects:objs forProperties:[self propertiesForEntityType:type]];
}

#pragma mark -

- (NSString *)description
{
	NSArray * values = self.values;
	
	if (!values.count)
		return @"";
	
	if (values.count == 1) {
		id obj = values[0];
		if ([obj respondsToSelector:@selector(description)])
			return [obj description];
		else
			return @"(?)";
	}
	
	return [NSString stringWithFormat:@"{%@}", [values componentsJoinedByString:@","]];
}

+ (NSArray *)propertiesForEntityType:(Class<CORMMapping>)type
{
	NSMutableArray * props = [NSMutableArray array];
	
	for (NSString * mappedKey in [type mappedKeys])
		[props addObject:[type propertyNameForMappedName:mappedKey]];
	
	return props;
}

- (NSArray *)propertiesForEntityType:(Class<CORMMapping>)type
{
	return [self.class propertiesForEntityType:type];
}

- (NSArray *)values
{
	return @[];
}

- (id)copyWithZone:(NSZone *)zone
{
	@throw [NSException exceptionWithName:@"Abstract class" reason:@"CORMKey is abstract and cannot be directly copied" userInfo:nil];
}

- (NSString *)whereClauseForEntityType:(Class<CORMMapping>)type
{
	NSArray * props = [self propertiesForEntityType:type],
			* values = [self values];
	
	if (props.count != values.count)
		return nil;
	
	NSMutableArray * clauses = [NSMutableArray arrayWithCapacity:props.count];
	
	for (int i = 0; i < props.count; i++)
		if ([values[i] isKindOfClass:NSNull.class])
			[clauses addObject:[NSString stringWithFormat:@"[%@] IS NULL", props[i]]];
		else
			[clauses addObject:[NSString stringWithFormat:@"[%@] = '%@'", props[i], values[i]]];
	
	return [clauses componentsJoinedByString:@" AND "];
}

@end
