//
//  Feedback.h
//  VinoCharts
//
//  Created by Ang Civics on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/* 
 Feedback model use to hold property that need to be saved only. Is a wrapper class for the NSManagedObject FeedbackModel class
*/

#import <Foundation/Foundation.h>
#import "FeedbackModel.h"

@interface Feedback : NSObject

@property(nonatomic,readwrite)NSString* title;
@property(nonatomic,readwrite)NSMutableArray* questionArray;
@property(nonatomic,readwrite)NSMutableArray* answerArray;

-(id)initWithCoreData:(FeedbackModel*)model;
//EFFECTS: This object will be init with the model data
//REQUIRES: model is not nil

-(id)initWithQuestionArray:(NSMutableArray*)qArray answerArray:(NSMutableArray*)aArray Title:(NSString*)title;
//REQUIRES: parameter passed in is correct
//EFFECTS: This model will be init with the passed in parameter

@end
