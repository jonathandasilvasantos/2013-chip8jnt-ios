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

    
    for(int pos=0; pos<64*32; pos++)
    {

        unsigned char pixel =gfx[pos];
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);

        
        int x, y; // we need to convert vetor to matriz
        y = pos/64;
        x = pos%64;

        CGRect rectangle = CGRectMake(100+ (x*4),y*4,4,4);
        if(pixel != 0) CGContextAddRect(context, rectangle);
    }
    CGContextStrokePath(context);
    

}

- (void)setGFX:(unsigned char*)array {
    gfx = array;
}
@end
