//
//  Model.m
//  VinoCharts
//
//  Created by Ang Civics on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Model.h"

@interface Model()

@property (readwrite) NSMutableArray* allProjects;

@end

@implementation Model

static Model *sharedModel = nil;

+(Model*)sharedModel{
    if(sharedModel == nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedModel = [[Model alloc] init];
        });
    }
    return sharedModel;
}

-(void)dataChanged{
    //EFFECTS: explicitly save the current state by overwriting, without depending on core data autosaving
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
}

-(Project *)createProjectModel{
    ProjectModel* coreDataProject = [NSEntityDescription insertNewObjectForEntityForName:kProject inManagedObjectContext:self.database.managedObjectContext];
    Project* project = [[Project alloc] initWithCoreData:coreDataProject];
    project.saveDelegate = self;
    [self.allProjects addObject:project];
    return project;
}

-(id)init{
    self = [super init];
    if(self){
        self.allProjects = [[NSMutableArray alloc]init];
        [self initContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importProjectFromTemporaryDirectoryPersistentStore) name:@"persistentStoreLoaded" object:nil];
    }
    return self;
}

-(void)initContext{
    // init and retrieve data from core data storage
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    url= [url URLByAppendingPathComponent:DATABASE];
    
    self.database = [[UIManagedDocument alloc]initWithFileURL:url];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        [self.database openWithCompletionHandler:^(BOOL success) {
            
            NSArray* fetchProject = [self loadProject];
            for (ProjectModel* p in fetchProject) {
                Project* pro = [[Project alloc] initWithCoreData:p];
                [self.allProjects addObject:pro];
            }
            [self.delegate projectLoaded];
            //NSLog(@"document exist and opened at %@",[url path]);
        }];
    }else{
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            //NSLog(@"document created at %@",[url path]);
        }];
    }
}

-(NSArray*)loadProject{
    //EFFECTS: return all core data project entity object
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* entity = [NSEntityDescription entityForName:kProject inManagedObjectContext:self.database.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSArray* fetchedObjects = [self.database.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return fetchedObjects;
}

-(void)removeProjectAtIndex:(int)index{
    Project* pro = [self.allProjects objectAtIndex:index];
    [pro removeFromCoreData];
    [self.allProjects removeObjectAtIndex:index];
    [self.delegate projectLoaded];
    [self dataChanged];
}

-(void)importProjectFromTemporaryDirectoryPersistentStore{
    NSURL* url = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    
    UIManagedDocument* doc = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        [doc openWithCompletionHandler:^(BOOL success) {
            NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription* entity = [NSEntityDescription entityForName:kProject inManagedObjectContext:doc.managedObjectContext];
            
            [fetchRequest setEntity:entity];
            
            NSArray* fetchedObjects = [doc.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            for(ProjectModel* pro in fetchedObjects){
                ProjectModel* model = [NSEntityDescription insertNewObjectForEntityForName:kProject inManagedObjectContext:self.database.managedObjectContext];
                [model copyProjectData:pro];
                Project* project = [[Project alloc]initWithCoreData:model];
                
                int index = [self isProjectExists:project.title];
                if(index != -1){
                    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Merge Project?" message:@"You have an existing project with the same title. Do you want to merge them or create a separate project?" delegate:self cancelButtonTitle:@"Separate" otherButtonTitles:@"Merge", nil];
                    alertView.tag = index;
                    [alertView show];
                }else{
                    [self promptChangeProjectName];
                }
                
                [self.allProjects addObject:project];//sequence matter, will detect same project if added before the check
            }
            [[NSFileManager defaultManager] removeItemAtURL:[url URLByAppendingPathComponent:STORE_CONTENT isDirectory:YES] error:nil];
            [self.delegate projectLoaded];
            [self dataChanged];
        }];
    }
}

-(BOOL)isUniqueProjectTitle:(NSString*)name{
    for(int i=0 ; i<self.allProjects.count-1 ; i++){
        if([[[(Project*)[self.allProjects objectAtIndex:i] title] capitalizedString] isEqualToString:[name capitalizedString]]){
            return NO;
        }
    }
    return YES;
}

-(void)promptChangeProjectName{
    UIAlertView *warningAlertView = [[UIAlertView alloc] initWithTitle:@"New Project Title"
                                                               message:@"Please enter a new project title below:"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Submit", nil];
    
    warningAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    warningAlertView.tag = 2;
    [warningAlertView show];
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if([alertView.title isEqualToString:@"New Project Title"]){
        if(buttonIndex==0){//cancel
            [self removeProjectAtIndex:self.allProjects.count-1];
        }else{
            NSString* title = [alertView textFieldAtIndex:0].text;
            if(![self isUniqueProjectTitle:title]){
                [self promptChangeProjectName];
            }else{
                [(Project*)self.allProjects.lastObject setTitle:title];
                [self.delegate projectLoaded];
            }
        }
    }else{//Merge Project
        if(buttonIndex != alertView.cancelButtonIndex){
            [self mergeProject:alertView.tag];
        }
        [self promptChangeProjectName];
    }
    
}

-(int)isProjectExists:(NSString*)name{
    for(int i=0 ; i<self.allProjects.count ; i++){
        if([[[(Project*)[self.allProjects objectAtIndex:i] title] capitalizedString] isEqualToString:[name capitalizedString]]){
            return i;
        }
    }
    return -1;
}

-(void)mergeProject:(int)i{
    Project* oldPro = [self.allProjects objectAtIndex:i];
    Project* newPro = self.allProjects.lastObject;
    for(Diagram* diagram in oldPro.diagrams){
        [newPro addDiagramsObject:diagram];
    }
    for(Feedback* feedback in oldPro.feedbacks){
        [newPro addFeedbacksObject:feedback];
    }
    for(Survey* survey in oldPro.surveys){
        [newPro addSurveysObject:survey];
    }
}
@end
