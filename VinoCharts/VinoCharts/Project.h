//
//  Project.h
//  VinoCharts
//
//  Created by Ang Civics on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/*  
 Project model use to hold property that need to be saved only. It is a wrapper class for the NSManagedObject ProjectModel class.
 Saving is done by using Core Data.
 Please create this Project class object by using the Model class createProjectModel method in order to link up with core data for saving purposes.
 Creating with normal init method will not have this object to be saved.
 Must use the provided method to modify the property, object added incorrectly will not be saved.
 property details and title is indirectly modifying the core data model
 */

#import <Foundation/Foundation.h>
#import "DropboxViewController.h"
#import "ProjectModel+Other.h"
#import "CoreDataConstant.h"
#import "Survey.h"
#import "SurveyModel+Other.h"
#import "Feedback.h"
#import "FeedbackModel+Other.h"
#import "Diagram.h"
#import "DiagramModel+Other.h"

@protocol SaveDelegate
-(void)dataChanged;
//REQUIRES: delegated is set
//EFFECTS: notify delegate the this project data is changed
@end

@protocol FileCreatedDelegate
-(void)fileCreated;
//REQUIRES: delegated is set
//EFFECTS: to notify that the persistent store consisting only this project data is created under tmp/project.title folder
@end

@interface Project : NSObject

@property (nonatomic) NSString * details;
@property (nonatomic) NSString * title;
@property (nonatomic,readonly) NSMutableArray *diagrams;
@property (nonatomic,readonly) NSMutableArray *feedbacks;
@property (nonatomic,readonly) NSMutableArray *surveys;

@property id<SaveDelegate> saveDelegate;
@property id<FileCreatedDelegate> fileDelegate;

- (id)initWithCoreData:(ProjectModel*)model;
//EFFECTS: This object will be init with the model data
//REQUIRES: model is not nil
- (void)removeFromCoreData;
//REQUIRES: This project is saved in a context
//EFFECTS: completely remove this project from core data context only

- (void)addDiagramsObject:(Diagram *)value;
//REQUIRES: The diagram is not nil
//EFFECTS: A DiagramModel entity is created in the same context with the project, initialise with the value data and saved
- (void)updateDiagramAtIndex:(int)index With:(Diagram*)value;
//REQUIRES: The index pass in is accurate and not out of bound
//EFFECTS: The DiagramModel entity data will be replaced by the passed in value data
- (void)removeDiagramAtIndex:(int)index;
//REQUIRES: The index pass in is accurate and not out of bound
//EFFECTS: The corresponding DiagramModel will be completely remove from saving and remove from this project array

- (void)addFeedbacksObject:(Feedback *)value;
//REQUIRES: The feedback is not nil
//EFFECTS: A FeedbackModel entity is created in the same context with the project, initialise with the value data and saved
- (void)removeFeedbackAtIndex:(int)index;
//REQUIRES: The index pass in is accurate and not out of bound
//EFFECTS: The corresponding FeedbackModel will be completely remove from saving and remove from this project array

- (void)addSurveysObject:(Survey *)value;
//REQUIRES: The diagram is not nil
//EFFECTS: A SurveyModel entity is created in the same context with the project, initialise with the value data and saved
- (void)updateSurveyAtIndex:(int)index With:(Survey*)value;
//REQUIRES: The index pass in is accurate and not out of bound
//EFFECTS: The SurveyModel entity data will be replaced by the passed in value data
- (void)removeSurveyAtIndex:(int)index;
//REQUIRES: The index pass in is accurate and not out of bound
//EFFECTS: The corresponding SurveyModel will be completely remove from saving and remove from this project array

-(void)createSingleProjectFileInTemporaryDirectory;
//REQUIRES: This project is already saved in the context
//EFFECTS: a persistentStore file consisting of only this project data will be created at path tmp\project.title folder

@end
