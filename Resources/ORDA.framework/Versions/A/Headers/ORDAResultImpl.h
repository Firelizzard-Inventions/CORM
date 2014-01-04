//
//  ORDAResultImpl.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "ORDAResult.h"

/**
 * ORDAResultImpl is an implementation of ORDAResult.
 */
@interface ORDAResultImpl : NSObject <ORDAResult>

@property (readonly) ORDAResultCode code;

+ (ORDAResultImpl *)resultWithCode:(ORDAResultCode)code;
- (id)initWithCode:(ORDAResultCode)code;
- (id)initWithSucessCode;

@end
