//
//  NSObject+abstractClass.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 4/10/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSObject (abstractClass)

+ (NSException *)_subclassImplementationExceptionFromMethod:(SEL)method isClassMethod:(BOOL)classMethod;

@end
