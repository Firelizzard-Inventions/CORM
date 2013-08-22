//
//  CORMEntityDict.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//
//  PRIVATE HEADER
//

#import "CORMEntityImpl.h"

@interface CORMEntityDict : CORMEntityImpl

@end

@interface CORMEntityDict (Genesis)

+ (Class)entityDictClassWithName:(NSString *)name andKeys:(NSArray *)keys andProperties:(NSArray *)properties andForeignKeys:(NSArray *)foreign;

@end