//
//  ORDADriver.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@protocol ORDAGovernor;

/**
 * The ORDADriver protocol is the protocol that all ORDA RDBMS drivers must
 * conform to. Instances of this class are not exposed to API consumers.
 */
@protocol ORDADriver <NSObject>

/** ----------------------------------------------------------------------------
 * @name Properties
 */

/**
 * This driver's URL scheme
 * @return the scheme
 * @discussion This returns the URL scheme that this driver is intended to
 * handle. This method is only intended to be used when registering drivers,
 * something that the API consumer should not need to do.
 */
- (NSString *)scheme;

/** ----------------------------------------------------------------------------
 * @name Governors
 */

/**
 * Generates a governor for a URL
 * @param URL the URL
 * @return the governor or an error result
 * @discussion This generates a driver based on the specified URL.
 * Implementation of this method is driver specific, as are possible non-success
 * codes. Codes should be of the kORDAResultCodeConnectionErrorSubclass
 * subclass.
 */
- (id<ORDAGovernor>)governorForURL:(NSURL *)url;

@end
