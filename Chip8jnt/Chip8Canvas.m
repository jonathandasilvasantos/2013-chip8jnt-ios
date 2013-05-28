//
//  Chip8Canvas.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 5/27/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "Chip8Canvas.h"

@implementation Chip8Canvas

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 3.0);


    for(int x=0; x<64; x++) {
        for(int y=0; y<32; y++) {
            int index = GFX_INDEXOF(x, y);
            unsigned short pixel = gfx[index];
            CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
            CGRect rectangle = CGRectMake((x*4),y*4,4,4);
            if(pixel != 0) CGContextAddRect(context, rectangle);
            
            CGContextStrokePath(context);
        }
    }
}

- (void)setPixel:(unsigned int)x y:(unsigned int)y value:(unsigned short)value {
    gfx[GFX_INDEXOF(x, y)] = value;
}

@end

