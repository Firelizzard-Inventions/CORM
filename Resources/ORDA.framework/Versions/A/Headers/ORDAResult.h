//
//  ORDAResult.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

#import "ORDAResultConsts.h"

/**
 * The ORDAResult protocol defines the base type for everything in the ORDA API.
 * Consumers of the API must be aware that, for any method that returns an
 * object that conforms to this protocol, that object can only be expected to
 * actually be the advertized type if it's code is kORDASuccessResultCode. If
 * the code is any other value, the object is likely an instance of some other
 * class, namely an error result class (not exposed by the API). Currently, the
 * only non-success codes are error codes, so if the code is non-success,
 * isError must be true. This may change in the future.
 */
@protocol ORDAResult <NSObject>

/** ----------------------------------------------------------------------------
 * @name Properties
 */

/**
 * The code of this result
 * @return the code
 */
- (ORDAResultCode)code;

/** ----------------------------------------------------------------------------
 * @name Classification
 */

/**
 * @return true if this result's code is an error code
 */
- (BOOL)isError;

@end