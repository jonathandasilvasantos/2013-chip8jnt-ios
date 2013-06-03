//
//  ViewController.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "ViewController.h"
#import "Chip8.h"
#import "Chip8jntUtils.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Receives notification from debug;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debugRefresh) name:@"debugRefresh" object:nil];

    // We create a object to execute some utils functions
    Chip8jntUtils *utils = [[Chip8jntUtils alloc] init];
    
    self.ch8 = [[Chip8 alloc] init];
    self.ch8.canvas = self.canvas;
    self.debugTable.dataSource = self.ch8;
    self.debugTable.delegate =self;
    
    // Print all roms names in console;
    NSLog(@"%@", [utils getAllRomsFilenames] );
    NSString *romName = @"ROM_NAME.ch8";

    
    [self.ch8 startWithRom:romName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 18;
}

- (void)debugRefresh {
    
    [self.debugTable reloadData];
}

- (IBAction)debugStep:(id)sender {
    [self.ch8 cycle]; // Run a emulate cycle;
}

@end
