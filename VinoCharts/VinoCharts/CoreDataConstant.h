//
//  CoreDataConstant.h
//  VinoCharts
//
//  Created by Ang Civics on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/*
 Constant needed for saving purposes
 */
#import <Foundation/Foundation.h>

@interface CoreDataConstant : NSObject

//Core data entity name, have to match with the class name
extern NSString* const kProject;
extern NSString* const kSurvey;
extern NSString* const kFeedback;
extern NSString* const kDiagram;

//Question class encode and decode key
extern NSString* const kTitle;
extern NSString* const kOption;
extern NSString* const kType;

//NoteM class encode and decode key
extern NSString* const kFont;
extern NSString* const kFontColor;
extern NSString* const kMaterial;
extern NSString* const kXLocation;
extern NSString* const kYLocation;
extern NSString* const kContent;

//Path location constant for saving destination
extern NSString* const DATABASE;
extern NSString* const PERSISTENT_STORE;
extern NSString* const STORE_CONTENT;
extern NSString* const DROPBOX_ROOT_PATH;
extern NSString* const PNG_SUFFIX;
extern NSString* const JPEG_SUFFIX;

@end
