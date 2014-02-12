//
//  Project.m
//  VinoCharts
//
//  Created by Ang Civics on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Project.h"

@interface Project ()

@property ProjectModel* coreDataModel;

@property (nonatomic,readwrite) NSMutableArray *diagrams;
@property (nonatomic,readwrite) NSMutableArray *feedbacks;
@property (nonatomic,readwrite) NSMutableArray *surveys;

@end

@implementation Project

-(void)removeFromCoreData{
    [self.coreDataModel.managedObjectContext deleteObject:self.coreDataModel];
    [self.saveDelegate dataChanged];
}

-(void)setTitle:(NSString *)title{
    self.coreDataModel.title = title;
    _title = title;
    [self.saveDelegate dataChanged];
    
}

-(void)setDetails:(NSString *)details{
    _details = details;
    self.coreDataModel.details = details;
    [self.saveDelegate dataChanged];
    
}

-(id)initWithCoreData:(ProjectModel *)model{
    self = [super init];
    if(self){
        self.title = model.title;
        self.details = model.details;
        
        self.diagrams = [[NSMutableArray alloc] init];
        for(DiagramModel* diagram in [model.diagrams allObjects]){
            [self.diagrams addObject:[[Diagram alloc] initWithCoreData:diagram]];
        }
        self.feedbacks = [[NSMutableArray alloc] init];
        for (FeedbackModel* feedback in [model.feedbacks allObjects]){
            [self.feedbacks addObject:[[Feedback alloc]initWithCoreData:feedback]];
        }
        self.surveys = [[NSMutableArray alloc] init];
        for (SurveyModel* survey in [model.surveys allObjects]){
            [self.surveys addObject:[[Survey alloc]initWithCoreData:survey]];
        }
        
        self.coreDataModel = model;
        [self.saveDelegate dataChanged];
        
    }
    return self;
}

- (void)addDiagramsObject:(Diagram *)value{
    DiagramModel* model = [NSEntityDescription insertNewObjectForEntityForName:kDiagram inManagedObjectContext:self.coreDataModel.managedObjectContext];
    [self.coreDataModel addDiagramsObject:model];
    model.project = self.coreDataModel;
    [model retrieveDiagramData:value];
    [self.diagrams addObject:value];
    [self.saveDelegate dataChanged];
    
}
-(void)updateDiagramAtIndex:(int)index With:(Diagram *)value{
    DiagramModel* model = [[self.coreDataModel.diagrams allObjects]objectAtIndex:index];
    [model retrieveDiagramData:value];
    [self.diagrams replaceObjectAtIndex:index withObject:value];
    [self.saveDelegate dataChanged];
}

-(void)removeDiagramAtIndex:(int)index{
    DiagramModel* model = [[self.coreDataModel.diagrams allObjects]objectAtIndex:index];
    [self.coreDataModel.managedObjectContext deleteObject:model];
    [self.diagrams removeObjectAtIndex:index];
    [self.saveDelegate dataChanged];
    
}

- (void)addFeedbacksObject:(Feedback *)value{
    FeedbackModel* model = [NSEntityDescription insertNewObjectForEntityForName:kFeedback inManagedObjectContext:self.coreDataModel.managedObjectContext];
    [self.coreDataModel addFeedbacksObject:model];
    model.project = self.coreDataModel;
    [model retrieveFeedbackData:value];
    [self.feedbacks addObject:value];
    [self.saveDelegate dataChanged];
    
}
-(void)removeFeedbackAtIndex:(int)index{
    FeedbackModel* feedback = [[self.coreDataModel.feedbacks allObjects]objectAtIndex:index];
    [self.coreDataModel.managedObjectContext deleteObject:feedback];
    [self.feedbacks removeObjectAtIndex:index];
    [self.saveDelegate dataChanged];
    
}

- (void)addSurveysObject:(Survey *)value{
    SurveyModel* model = [NSEntityDescription insertNewObjectForEntityForName:kSurvey inManagedObjectContext:self.coreDataModel.managedObjectContext];
    [self.coreDataModel addSurveysObject:model];
    model.projectModel = self.coreDataModel;
    [model retrieveSurveyData:value];
    [self.surveys addObject:value];
    [self.saveDelegate dataChanged];
    
}
-(void)updateSurveyAtIndex:(int)index With:(Survey *)value{
    SurveyModel* survey = [[self.coreDataModel.surveys allObjects] objectAtIndex:index];
    [survey retrieveSurveyData:value];
    [self.surveys replaceObjectAtIndex:index withObject:value];
    [self.saveDelegate dataChanged];
    
}
-(void)removeSurveyAtIndex:(int)index{
    SurveyModel* survey = [[self.coreDataModel.surveys allObjects] objectAtIndex:index];
    [self.coreDataModel.managedObjectContext deleteObject:survey];
    [self.surveys removeObjectAtIndex:index];
    [self.saveDelegate dataChanged];
    
}

-(void)createSingleProjectFileInTemporaryDirectory{
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.title];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];

    NSURL* url = [NSURL fileURLWithPath:path];

    url= [url URLByAppendingPathComponent:DATABASE];
    
    UIManagedDocument* tempDatabase = [[UIManagedDocument alloc]initWithFileURL:url];
    
    [tempDatabase saveToURL:tempDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        ProjectModel* project = [NSEntityDescription insertNewObjectForEntityForName:kProject inManagedObjectContext:tempDatabase.managedObjectContext];
        [project copyProjectData:self.coreDataModel];
        //for running on iPad. if running on simulator, need to use saveUrl
        [tempDatabase closeWithCompletionHandler:^(BOOL success) {
            [self.fileDelegate fileCreated];
        }];
    }];
    
}
@end
