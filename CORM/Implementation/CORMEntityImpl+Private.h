//
//  CORMEntityImpl_Private.h
//  CORM
//
//  Created by Ethan Reesor on 11/25/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityImpl.h"

@interface _BoundObjectData : NSObject

@property (readonly) id proxy, object;
@property (readonly) NSArray * names;

- (id)initWithProxy:(id<NSObject>)proxy andObject:(id<NSObject>)object names:(NSArray *)names;

@end

@interface CORMEntityImpl (Private)

- (void)invalidate;

- (id)initByBindingTo:(id)obj;

@end
