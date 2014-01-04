//
//  ORDATableResult.h
//  ORDA
//
//  Created by Ethan Reesor on 8/24/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ORDAResult.h"

/**
 * The ORDATableResult protocol is the protocol that all results from ORDATable
 * must conform to.
 */
@protocol ORDATableResult <ORDAResult, NSFastEnumeration>

/**
 * @return the number of contained result rows
 */
- (NSUInteger)count;

/**
 * @param idx the index
 * @return the idx'th result row contained in this result object/array.
 */
- (id)objectAtIndexedSubscript:(NSUInteger)idx;



@end
