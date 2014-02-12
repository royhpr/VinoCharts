//
//  NoteM.h
//  VinoCharts
//
//  Created by Ang Civics on 11/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*  
 Note model for the Note viewController class that hold the property that need to be safe only. 
 Saving is done by encoding and decoding. 
 Use string to identify a color RGB value instead of UIColor.
*/

#import <Foundation/Foundation.h>
#import "CoreDataConstant.h"

@interface NoteM : NSObject

@property (nonatomic) NSString * content;
@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) NSString * fontColor;
@property (nonatomic) NSString * material;
@property (nonatomic) UIFont * font;

-(id)initDefaultWithContent:(NSString*)noteContent;
//EFFECT: Ctor for initialising with a default note with content.
//REQUIRES: noteContent of appropriate length.

+(id)defaultModelWithContent:(NSString*)noteContent;
//EFFECT: Lazy ctor for initialising with content.
//REQUIRES: noteContent of appropriate length.

@end
