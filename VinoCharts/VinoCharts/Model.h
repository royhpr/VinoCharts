//
//  Model.h
//  VinoCharts
//
//  Created by Ang Civics on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/*
 This is singleton class. Must use the createProjectModel to get a using core data Project model. allProjects need to be always up-to-date for any creation, deletion and merging of project if using the provided method correctly.
*/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataConstant.h"
#import "Project.h"
#import "ProjectModel+Other.h"

@protocol ModelDelegate
-(void)projectLoaded;
//REQUIRES: The delegate is set up properly
//EFFECTS: notify whenever there are changes on the allprojects array
@end

@interface Model : NSObject<SaveDelegate,UIAlertViewDelegate>

@property UIManagedDocument* database;//for core data saving

@property (readonly) NSMutableArray* allProjects;//will always be accurate

@property id<ModelDelegate> delegate;

+(id)sharedModel;
// Singleton object

-(Project*)createProjectModel;
// EFFECTS: create a ProjectModel entity for core data saving and return a new Project object that is link to the coresponding entity

-(void)removeProjectAtIndex:(int)index;
// REQUIRE: the project at the corresponding index exist and not out of bound
// EFFECTS: remove project from allProjects array and from core data saving

-(void)importProjectFromTemporaryDirectoryPersistentStore;
// REQUIRE: the persistenStore exist at tmp directory with path: Database/StoreContent/persistentStore
// EFFECTS: will create and add the project into local persistentStore
// this method is called by NSNotification center, observer is added when init this object

@end
