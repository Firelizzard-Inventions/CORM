//
//  CORM.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@class CORMStore;

@interface CORM : NSObject

+ (CORMStore *)defaultStore;
+ (void)setDefaultStore:(CORMStore *)store;

@end
