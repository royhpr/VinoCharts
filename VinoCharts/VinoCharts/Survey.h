//
//  Survey.h
//  VinoCharts
//
//  Created by Ang Civics on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/* Survey model use to hold survey property that need to be saved only. Is a wrapper class for the NSManagedObject SurveyModel class
 */
#import <Foundation/Foundation.h>
#import "SurveyModel.h"
#import "Question.h"

@interface Survey : NSObject

@property (nonatomic) NSString * detail;
@property (nonatomic) NSString * title;
@property (nonatomic) NSMutableArray *questions;

-(id)initWithCoreData:(SurveyModel*)model;
//EFFECTS: This object will be init with the model data
//REQUIRES: model is not nil

-(void)updateQuestionWithTitle:(NSString*)QTitle Type:(NSString*)QType Options:(NSArray*)QOptions Index:(int)index;
//REQUIRES: index need to be accurate and not out of bound
//EFFECTS: the corresponding question is replaced with passed in parameter
-(void)addEmptyQuestion;
//REQUIRES: questions array is initialised
//EFFECTS: Question model without meaningful data is created and added to the questions array
-(int)getNumberOfQuestion;
//REQUIRES: questions array is initialised
//EFFECTS: return the counts questions array
-(void)deleteQuestionAtIndex:(int)index;
//REQUIRES: index need to be accurate and not out of bound
//EFFECTS: corresponding question will be removed

-(NSArray*)getQuestionInfoWithIndex:(int)index;
//REQUIRES: index need to be accurate and not out of bound
//EFFECTS: corresponding question info array [title,type,options] will be returned

@end
