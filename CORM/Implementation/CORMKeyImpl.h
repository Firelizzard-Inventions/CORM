//
//  CORMKey.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

#import "CORMKey.h"

@protocol CORMEntity;

@interface CORMKeyImpl : NSArray <CORMKey>

@end

@interface CORMRowidKey : CORMKeyImpl

@end