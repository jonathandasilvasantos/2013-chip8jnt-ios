//
//  Chip8Canvas.h
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 5/27/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chip8jntUtils.h"

@interface Chip8Canvas : UIView {
    unsigned short gfx[64*32];
}

- (void)setPixel:(unsigned int)x y:(unsigned int)y value:(unsigned short)value;
@end
