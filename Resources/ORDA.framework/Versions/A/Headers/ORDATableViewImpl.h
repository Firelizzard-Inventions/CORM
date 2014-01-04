//
//  ORDATableViewImpl.h
//  ORDA
//
//  Created by Ethan Reesor on 11/29/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "ORDAResultImpl.h"
#import "ORDATableView.h"

@protocol ORDAStatement;

@interface ORDATableViewImpl : ORDAResultImpl <ORDATableView>

- (void)reload;

@end
