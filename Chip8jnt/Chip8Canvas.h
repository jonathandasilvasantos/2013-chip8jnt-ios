//
//  Chip8Canvas.h
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 5/27/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Chip8Canvas : UIView {
    unsigned char *gfx;
}

- (void)setGFX:(unsigned char*)array;
@end
