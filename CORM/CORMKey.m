//
//  CORMKey.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMKey.h"

#import "CORMEntity.h"

@interface CORMKey (Private)

+ (NSString *)_description:(id)obj;

@end

#pragma mark -

@implementation CORMKey {
	NSArray * _backing;
}

- (NSString *)description
{
	if (!self.count)
		return @"";
	
	if (self.count == 1)
		return [CORMKey _description:self[0]];
	
	return [NSString stringWithFormat:@"{%@}", [self componentsJoinedByString:@","]];
}

- (BOOL)isEqual:(id)object
{
	if (object && ![object isKindOfClass:[CORMKey class]])
		return NO;
	
	return [self.description isEqualToString:[CORMKey _description:object]];
}

- (NSString *)whereClauseForEntityType:(Class<CORMEntity>)type
{
	NSArray * keyNames = [type mappedKeys];
	NSMutableArray * clauses = [NSMutableArray array];
	
	for (int i = 0; i < keyNames.count && i < self.count; i++)
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

@end

@implementation CORMKey (Genesis)

+ (id)key
{
	return [CORMKey keyWithArray:@[]];
}

+ (id)keyWithDescriptor:(NSString *)string
{
	BOOL prefix = [string hasPrefix:@"{"];
	BOOL suffix = [string hasSuffix:@"}"];
	
	if (prefix ^ suffix)
		return nil;
	
	if (!prefix && !suffix)
		return [CORMKey keyWithArray:@[string]];
	
	return [CORMKey keyWithArray:[[string substringWithRange:NSMakeRange(1, string.length - 1)] componentsSeparatedByString:@","]];
}

+ (id)keyWithObject:(id)obj
{
	if (!obj)
		return nil;
	
	if ([obj isKindOfClass:self])
		return obj;
	
	if ([obj isKindOfClass:[NSString class]])
		return [CORMKey keyWithDescriptor:obj];
	
	if ([obj isKindOfClass:[NSArray class]])
		return [CORMKey keyWithArray:obj];
	
	return [CORMKey keyWithArray:@[obj]];
}

+ (id)keyWithArray:(NSArray *)arr
{
	if (!arr)
		return nil;
	
	if (![arr respondsToSelector:@selector(count)] || ![arr respondsToSelector:@selector(objectAtIndexedSubscript:)])
		return nil;
	
	if (!arr.count)
		return nil;
	
	return [[[CORMKey alloc] initWithArray:arr] autorelease];
}

+ (id)keyWithObjects:(id)obj, ...
{
	NSMutableArray * arr = @[].mutableCopy;
	
	va_list vargs;
	va_start(vargs, obj);
	for (; obj; obj = va_arg(vargs, id))
		[arr addObject:obj];
	va_end(vargs);
	
	id key = [CORMKey keyWithArray:arr];
	[arr release];
	return key;
}

+ (id)keyWithObjects:(const void *)objs count:(NSUInteger)count
{
	return [CORMKey keyWithArray:[NSArray arrayWithObjects:objs count:count]];
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

@implementation CORMKey (Private)

+ (NSString *)_description:(id)obj;
{
	if ([obj respondsToSelector:@selector(description)])
		return [obj description];
	else
		return @"(?)";
}

@end
