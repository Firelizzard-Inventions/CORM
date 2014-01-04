//
//  ORDA_Private.h
//  ORDA
//
//  Created by Ethan Reesor on 8/23/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "ORDA.h"

@interface ORDA ()

/** ----------------------------------------------------------------------------
 * @name Properties
 */

/**
 * The currently registered drivers
 * @discussion This provides a mechanism by which the currently registered
 * drivers can be retreived. I'm not sure why this exists.
 */
@property (readonly) NSArray * registeredDrivers;

@end
