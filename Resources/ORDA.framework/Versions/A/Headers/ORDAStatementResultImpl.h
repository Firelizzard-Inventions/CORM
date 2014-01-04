//
//  ORDAStatementResultImpl.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "ORDAResultImpl.h"

#import "ORDAStatementResult.h"

/**
 * ORDAStatementResultImpl is an implementation of ORDAStatementResult.
 */
@interface ORDAStatementResultImpl : ORDAResultImpl <ORDAStatementResult>

@property (readonly) long long changed;
@property (readonly) long long lastID;
@property (readonly) NSDictionary * dict;
@property (readonly) NSArray * array;

//+ (NSDictionary *)arrayDictFromDictArray:(NSArray *)array andRows:(int)rows andColumns:(NSArray *)columns;
//+ (NSArray *)dictArrayFromArrayDict:(NSDictionary *)dict andRows:(int)rows andColumns:(NSArray *)columns;

+ (ORDAStatementResultImpl *)statementResultWithChanged:(long long)changed andLastID:(long long)lastID andRows:(long)rows andColumns:(NSArray *)columns andDictionaryOfArrays:(NSDictionary *)dict andArrayOfDictionaries:(NSArray *)array;
- (id)initWithChanged:(long long)changed andLastID:(long long)lastID andRows:(long)rows andColumns:(NSArray *)columns andDictionaryOfArrays:(NSDictionary *)dict andArrayOfDictionaries:(NSArray *)array;

@end
