//
//  FeedbackModel+Other.h
//  VinoCharts
//
//  Created by Ang Civics on 7/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "FeedbackModel.h"
#import "Feedback.h"
#import "CoreDataConstant.h"

@interface FeedbackModel (Other)

-(id)copyFeedbackData:(FeedbackModel *)feedback;
//REQUIRES: self is created in the correct context and the feedback is not nil
//EFFECTS: copy all feedback data to replace self data

-(void)retrieveFeedbackData:(Feedback*)feedback;
//REQUIRES: self is created in the correct context and the feedback is not nil
//EFFECTS: translate feedback class data to match core data saving type then modify self property

@end
