//
//  CORMClass.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

#import <ORDA/ORDA.h>

@protocol CORMEntity;
@class CORMStore;

@interface CORMFactory : NSObject

@property (readonly) Class<CORMEntity> type;
@property (readonly) id<ORDATable> table;
@property (readonly) CORMStore * store;

@end