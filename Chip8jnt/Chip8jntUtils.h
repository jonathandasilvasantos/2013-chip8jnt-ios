//
//  Chip8jntUtils.h
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GFX_WIDTH 64
#define GFX_INDEXOF(x,y) ((y*GFX_WIDTH) + x)

@interface Chip8jntUtils : NSObject

- (NSArray*)getAllRomsFilenames; // List in console all avaliable roms

@end
