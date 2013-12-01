//
//  CORMKey.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMKeyImpl.h"

#import "CORMEntity.h"

@interface CORMKeyImpl (Private)

+ (NSString *)_description:(id)obj;

@end

#pragma mark -

@implementation CORMKeyImpl {
	NSArray * _backing;
}

- (NSString *)description
{
	if (!self.count)
		return @"";
	
	if (self.count == 1)
		return [self.class _description:self[0]];
	
	return [NSString stringWithFormat:@"{%@}", [self componentsJoinedByString:@","]];
}

- (BOOL)isEqual:(id)object
{
	if (object && ![object isKindOfClass:self.class])
		return NO;
	
	return [self.description isEqualToString:[self.class _description:object]];
}

- (NSString *)whereClauseForEntityType:(Class<CORMEntity>)type
{
	NSArray * keyNames = [type mappedKeys];
	NSMutableArray * clauses = [NSMutableArray array];
	
	for (int i = 0; i < keyNames.count && i < self.count; i++)
		if ([self[i] isKindOfClass:NSNull.class])
			[clauses addObject:[NSString stringWithFormat:@"[%@] IS NULL", keyNames[i]]];
		else
			[clauses addObject:[NSString stringWithFormat:@"[%@] = '%@'", keyNames[i], self[i]]];
	
	return [clauses componentsJoinedByString:@" AND "];
}

- (NSUInteger)count
{
	return _backing.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
	return [_backing objectAtIndex:index];
}

+ (CORMKeyImpl *)key
{
	return [self keyWithArray:@[]];
}

+ (CORMRowidKey *)keyWithRowid:(NSNumber *)rowid
{
	return [CORMRowidKey keyWithObject:rowid];
}

+ (CORMKeyImpl *)keyWithDescriptor:(NSString *)string
{
	BOOL prefix = [string hasPrefix:@"{"];
	BOOL suffix = [string hasSuffix:@"}"];
	
	if (prefix ^ suffix)
		return nil;
	
	if (!prefix && !suffix)
		return [self keyWithArray:@[string]];
	
	return [self keyWithArray:[[string substringWithRange:NSMakeRange(1, string.length - 1)] componentsSeparatedByString:@","]];
}

+ (CORMKeyImpl *)keyWithObject:(id)obj
{
	if (!obj)
		return nil;
	
	if ([obj isKindOfClass:self])
		return obj;
	
	if ([obj isKindOfClass:[NSString class]])
		return [self keyWithDescriptor:obj];
	
	if ([obj isKindOfClass:[NSArray class]])
		return [self keyWithArray:obj];
	
	return [self keyWithArray:@[obj]];
}

+ (CORMKeyImpl *)keyWithArray:(NSArray *)arr
{
	if (!arr)
		return nil;
	
	if (![arr respondsToSelector:@selector(count)] || ![arr respondsToSelector:@selector(objectAtIndexedSubscript:)])
		return nil;
	
	if (!arr.count)
		return nil;
	
	return [[[self alloc] initWithArray:arr] autorelease];
}

+ (CORMKeyImpl *)keyWithObjects:(id)obj, ...
{
	NSMutableArray * arr = @[].mutableCopy;
	
	va_list vargs;
	va_start(vargs, obj);
	for (; obj; obj = va_arg(vargs, id))
		[arr addObject:obj];
	va_end(vargs);
	
	id key = [self keyWithArray:arr];
	[arr release];
	return key;
}

+ (CORMKeyImpl *)keyWithObjects:(const void *)objs count:(NSUInteger)count
{
	return [self keyWithArray:[NSArray arrayWithObjects:objs count:count]];
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
	if (!(self = [super init]))
		return nil;
	
	_backing = [[NSArray alloc] initWithObjects:objects count:cnt];
	
	return self;
}

- (void)dealloc
{
	[_backing release];
	
	[super dealloc];
}

@end

@implementation CORMKeyImpl (Private)

+ (NSString *)_description:(id)obj;
{
	if ([obj respondsToSelector:@selector(description)])
		return [obj description];
	else
		return @"(?)";
}

@end

#pragma mark -
#pragma mark -

@implementation CORMRowidKey

- (NSString *)whereClauseForEntityType:(Class)type
{
	return [NSString stringWithFormat:@"[rowid] = %@", self[0]];
}

@end
