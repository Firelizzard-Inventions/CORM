//
//  ORDAStatementImpl.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "ORDAStatement.h"
#import "ORDAResultImpl.h"

@protocol ORDAGovernor;

/**
 * ORDAStatementImpl is a partial implementation of ORDAStatement.
 */
@interface ORDAStatementImpl : ORDAResultImpl <ORDAStatement>

@property (readonly) NSString * statementSQL;
@property (readonly) id<ORDAGovernor> governor;

+ (ORDAStatementImpl *)statementWithGovernor:(id<ORDAGovernor>)governor withSQL:(NSString *)SQL;
- (id)initWithGovernor:(id<ORDAGovernor>)governor withSQL:(NSString *)SQL;

@end
