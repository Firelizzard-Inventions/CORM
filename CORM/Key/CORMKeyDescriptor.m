//
//  CORMKeyDescriptor.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMKeyDescriptor.h"

#import "CORMKey+Private.h"

@implementation CORMKeyDescriptor {
	NSArray * _values;
}

+ (instancetype)keyWithDescriptor:(NSString *)string
{
	return [[[self alloc] initWithDescriptor:string] autorelease];
}

- (id)initWithDescriptor:(NSString *)string
{
	if (!(self = [super init]))
		return nil;
	
	_descriptor = string.retain;
	_values = nil;
	
	return self;
}

- (void)dealloc
{
	[_descriptor release];
	[_values release];
	
	return [super dealloc];
}

- (NSArray *)values
{
	if (_values)
		goto _return;
	
	BOOL prefix = [self.descriptor hasPrefix:@"{"];
	BOOL suffix = [self.descriptor hasSuffix:@"}"];
	
	if (prefix ^ suffix)
		return nil;
	
	if (!prefix && !suffix)
		_values = @[self.descriptor];
	else
		_values = [[self.descriptor substringWithRange:NSMakeRange(1, self.descriptor.length - 1)] componentsSeparatedByString:@","];
	
	[_values retain];
	
_return:
	return _values;
}

- (NSString *)description
{
	return self.descriptor;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[self.class allocWithZone:zone] initWithDescriptor:self.descriptor];
}

@end
