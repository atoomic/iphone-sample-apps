/*
 Copyright (c) 2008, 2ndSite Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the <ORGANIZATION> nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "QueueViewController.h"
#import "FreshbooksAPI.h"
#import "QueueViewTableCell.h"

@implementation QueueViewController

@synthesize selectedEntry;
@synthesize rootViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQueueLengthChanged:) name:@"Queue Length Changed" object:nil];
	}
	return self;
}

 - (void)viewDidLoad {
	syncButton.titleShadowOffset = CGSizeMake(0.0, -1.0);
	tableView.rowHeight = 92.0;
	
	NSInteger queue_size = [[[FreshbooksAPI sharedInstance] timeEntryQueue] size];
	if(queue_size > 0){
	 syncButton.enabled = YES;
	}
	else {
	 syncButton.enabled = NO;
	}
 }

- (void)handleQueueLengthChanged:(NSNotification *) notification {
	NSInteger queue_size = [[[FreshbooksAPI sharedInstance] timeEntryQueue] size];
	
	if(queue_size > 0){
		syncButton.enabled = YES;
	}
	else {
		syncButton.enabled = NO;
	}
	
	[tableView reloadData];
}

- (IBAction) retryButtonClicked: (id)sender {
//	[self.selectedEntry setValue:nil forKey:@"isInvalid"];
	//TODO: clear invalid state for all entries
	NSMutableArray *entries = [[[FreshbooksAPI sharedInstance] timeEntryQueue] queue];
	for (NSInteger i = 0; i < [entries count]; ++i) {
		[[entries objectAtIndex:i] setValue:nil forKey:@"isInvalid"];
	}

	[[[FreshbooksAPI sharedInstance] timeEntryQueue] submitNextEntry];
}

- (IBAction) deleteButtonClickedFor: (NSMutableDictionary *) entry{
	self.selectedEntry = entry;
	deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this entry?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
	[deleteSheet showInView:[rootViewController view]];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

- (void) viewWillDisappear: (BOOL) animated {
	// Hide details and show "select something" prompt
	selectPromptLabel.alpha = 1.0;
	detailsView.hidden = YES;
	detailsView.alpha = 0.0;
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet == deleteSheet && buttonIndex == 0){
		[[[[FreshbooksAPI sharedInstance] timeEntryQueue] queue] removeObject: self.selectedEntry];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Queue Length Changed" object:nil];

		[deleteSheet release];
		deleteSheet = nil;
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	if(actionSheet == deleteSheet){
		[deleteSheet release];
		deleteSheet = nil;
	}
}


#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id cell = [tv dequeueReusableCellWithIdentifier:@"DetailCell"];
	if(cell == nil){
		cell = [[[NSBundle mainBundle] loadNibNamed:@"QueueViewCell" owner:[[[NSObject alloc] init] autorelease] options:[NSDictionary dictionary]] objectAtIndex:0];
		[cell setTableController: self];
	}

	NSInteger position = [indexPath indexAtPosition:1];
	NSMutableArray *queue = [[[FreshbooksAPI sharedInstance] timeEntryQueue] queue];
	if([queue count] > position){
		[cell setEntry:[queue objectAtIndex:position]];
	}
	else{
		[cell setEntry:nil];
	}
	
	[cell update];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger size = [[[FreshbooksAPI sharedInstance] timeEntryQueue] size];
	if(size > 4){
		return size;
	}
	else{
		return 4;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableArray *queue = [[[FreshbooksAPI sharedInstance] timeEntryQueue] queue];
	NSInteger index = [indexPath indexAtPosition:1];
	
	if([queue count] > index){
	
		NSMutableDictionary *entry = [queue objectAtIndex:index];
		self.selectedEntry = entry;

		// Show error message
		if([entry valueForKey:@"errorMessage"]){
			[[[[UIAlertView alloc] initWithTitle:@"Invalid Entry" 
										message:[entry valueForKey:@"errorMessage"] delegate:nil 
										cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
		}
	}
}




@end
