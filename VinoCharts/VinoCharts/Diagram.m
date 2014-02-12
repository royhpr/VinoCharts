//
//  Diagram.m
//  VinoCharts
//
//  Created by Ang Civics on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Diagram.h"
#import "Constants.h"
#import "GzColors.h"

@implementation Diagram

-(id)initWithCoreData:(DiagramModel *)model{
    self = [super init];
    if(self){
        self.title = model.title;
        self.width = [model.width doubleValue];
        self.height = [model.height doubleValue];
        self.color = model.color;
        self.unplacedNotes = [NSKeyedUnarchiver unarchiveObjectWithData:model.unplacedNotes];
        self.placedNotes = [NSKeyedUnarchiver unarchiveObjectWithData:model.placedNotes];
    }
    return self;
}

//-(id)init{
//    self = [super init];
//    if(self){
//        //height and weight are primitive data types.
//        _title = [[NSString alloc]init];
//        _placedNotes = [[NSMutableArray alloc]init];
//        _unplacedNotes = [[NSMutableArray alloc]init];
//        _color = [[NSString alloc]init];
//    }
//    return self;
//}

-(id)initDefaultWithTitle:(NSString*)myTitle{
    self = [super init];
    if(self){
        _width = CANVAS_DEFAULT_WIDTH;
        _height = CANVAS_DEFAULT_HEIGHT;
        _title = myTitle;
        _placedNotes = [[NSMutableArray alloc]init]; //empty
        _unplacedNotes = [[NSMutableArray alloc]init]; //empty
        _color = CANVAS_DEFAULT_COLOR_IN_GZCOLORHEXVALUE;
    }
    return self;
}

+(id)defaultWithTitle:(NSString*)myTitle{
    Diagram* dM = [[Diagram alloc]initDefaultWithTitle:myTitle];
    return dM;
}

-(void)setDimensionsWidth:(double)w Height:(double)h{
    _width = w;
    _height = h;
}

@end
