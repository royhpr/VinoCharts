//
//  DiagramModel+Other.m
//  VinoCharts
//
//  Created by Ang Civics on 7/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DiagramModel+Other.h"

@implementation DiagramModel (Other)

-(void)retrieveDiagramData:(Diagram *)value{
    self.title = value.title;
    self.width = [NSNumber numberWithDouble: value.width];
    self.height = [NSNumber numberWithDouble:value.height];
    self.color = value.color;
    self.placedNotes = [NSKeyedArchiver archivedDataWithRootObject:value.placedNotes];
    self.unplacedNotes = [NSKeyedArchiver archivedDataWithRootObject:value.unplacedNotes];
}

-(id)copyDiagramData:(DiagramModel *)diagram{
    [self setHeight:diagram.height];
    [self setWidth:diagram.width];
    [self setTitle:diagram.title];
    [self setColor:diagram.color];
    [self setUnplacedNotes:diagram.unplacedNotes];
    [self setPlacedNotes:diagram.placedNotes];
    
    return self;
}
@end
