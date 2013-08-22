//
//  Album.h
//  CORM
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <CORM/CORMEntityImpl.h>

@interface Album : CORMEntityImpl

@property (retain) NSNumber * albumID, * artistID;
@property (retain) NSString * title;

@end
