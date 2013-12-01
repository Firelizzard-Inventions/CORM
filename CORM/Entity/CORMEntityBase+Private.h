//
//  CORMEntityBase.h
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityBase.h"

#import "CORMEntity+Private.h"

@interface CORMEntityBase (Private)

- (NSMutableArray *)bound;

- (void)clearKey;

@end

@interface _BoundObjectData : NSObject

@property (readonly) id proxy, object;
@property (readonly) NSArray * names;

- (id)initWithProxy:(id<NSObject>)proxy andObject:(id<NSObject>)object names:(NSArray *)names;

@end