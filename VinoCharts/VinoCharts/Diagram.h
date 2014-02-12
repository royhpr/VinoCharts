//
//  Diagram.h
//  VinoCharts
//
//  Created by Ang Civics on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 Diagram model use to hold property that need to be saved only. Is a wrapper class for the NSManagedObject DiagramModel class
 */
#import <Foundation/Foundation.h>
#import "DiagramModel.h"
#import "NoteM.h"

@interface Diagram : NSObject


@property (nonatomic) double height;
@property (nonatomic) NSString * title;
@property (nonatomic) double width;
@property (nonatomic) NSMutableArray *placedNotes;
@property (nonatomic) NSMutableArray *unplacedNotes;
@property NSString* color;

-(id)initWithCoreData:(DiagramModel*)model;
//EFFECTS: This object will be init with the model data
//REQUIRES: model is not nil

-(id)initDefaultWithTitle:(NSString*)myTitle;
// EFFECT: Default ctor for initialising an empty canvas. Empty note arrays.
// REQUIRES: myTitle of appropriate length.

+(id)defaultWithTitle:(NSString*)myTitle;
// DESC: lazy constructor
// EFFECT: Default ctor for initialising an empty canvas. Empty note arrays.
// REQUIRES: myTitle of appropriate length.

-(void)setDimensionsWidth:(double)w Height:(double)h;
// EFFECT: Sets the width and height of the diagram.
// REQUIRES: arguments of appropriate lengths.

@end
