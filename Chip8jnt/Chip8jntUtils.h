//
// This file is part of Chip8jnt-iOS.
//
// Chip8jnt-iOS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Chip8jnt-iOS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//
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
