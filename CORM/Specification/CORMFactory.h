//
//  CORMFactory.h
//  CORM
//
//  Created by Ethan Reesor on 8/28/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CORMEntity;
@class CORMStore, CORMKey;

@protocol CORMFactory <NSObject>

- (Class<CORMEntity>)type;
- (CORMStore *)store;

- (id<CORMEntity>)entityForKey:(id)key;
- (id<CORMEntity>)entityOrProxyForKey:(id)key;

@end