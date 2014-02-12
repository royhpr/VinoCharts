//
//  DiagramModel.h
//  VinoCharts
//
//  Created by Ang Civics on 20/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectModel;

@interface DiagramModel : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSData * placedNotes;
@property (nonatomic, retain) NSData * unplacedNotes;
@property (nonatomic, retain) ProjectModel *project;

@end
