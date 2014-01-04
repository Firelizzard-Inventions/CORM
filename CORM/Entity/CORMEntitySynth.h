//
//  CORMEntitySynth.h
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityBase.h"

@interface CORMEntitySynth : CORMEntityBase

@end

@interface CORMEntitySynth (Synthesis)

+ (Class)synthesizeClassForNameWithDefaultStore:(NSString *)className;
+ (Class)synthesizeClassForName:(NSString *)className withStore:(CORMStore *)store;

@end