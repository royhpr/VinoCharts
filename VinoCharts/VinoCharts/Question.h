//
//  Question.h
//  VinoCharts
//
//  Created by Ang Civics on 11/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/* 
 This Question model saving is done by encoding and decoding, only hold property that need to be saved
 */
#import <Foundation/Foundation.h>
#import "CoreDataConstant.h"

@interface Question : NSObject

@property NSString* title;
@property NSArray* options;
@property NSString* type;

-(NSArray*)getInfo;
//REQUIRES: the needed info, title, options and type is not nil
//EFFECTS: return an array with info following sequences: title, type, options

@end
