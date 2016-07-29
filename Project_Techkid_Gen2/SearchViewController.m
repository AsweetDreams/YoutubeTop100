//
//  SearchViewController.m
//  Project_Techkid_Gen2
//
//  Created by ADMIN on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "SearchViewController.h"
#import "SWRevealViewController.h"
#import "YoutubeAPI.h"
#import "Video.h"
#import "PlaylistSearch.h"
#import "Channel.h"
#import "ItemCell.h"

#define _SEARCHBAR_STATE_ [self searchBarState]
#define _SEGMENT_STATE_ [self segmentState]
#define _SEARCH_VIDEO_RESULT_STATE_ [self searchVideoResultState]
#define _SEARCH_ALBUM_RESULT_STATE_ [self searchAlbumResultState]
#define _SEARCH_CHANNEL_RESULT_STATE_ [self searchChannelResultState]
#define _SEARCH_SUGGESTION_STATE_ [self searchSuggestionState]
#define _TYPE_ _type[@(_SEGMENT_STATE_)]

static NSString *sCellSuggestion = @"cellSuggestion";
static NSString *sCellVideoResult = @"cellVideoResult";
static NSString *sCellAlbumResult = @"cellAlbumResult";
static NSString *sCellChannelResult = @"cellChannelResult";

typedef enum {
    
    SEARCHBAR_STATE_VIDEO = 0,
    SEARCHBAR_STATE_ALBUM = 1,
    SEARCHBAR_STATE_CHANNEL = 2
    
} SEARCHBAR_STATE;

typedef enum {
    
    SEGMENT_STATE_VIDEO = 0,
    SEGMENT_STATE_ALBUM = 1,
    SEGMENT_STATE_CHANNEL = 2
    
} SEGMENT_STATE;

typedef enum {
    
    SEARCH_SUGGESTION_STATE_HIDDEN = 0,
    SEARCH_SUGGESTION_STATE_SHOW = 1,
    SEARCH_SUGGESTION_STATE_LOADED = 2
    
} SEARCH_SUGGESTION_STATE;


@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSArray     *_listSuggestion;
    NSArray     *_listVideoResult;
    NSArray     *_listAlbumResult;
    NSArray     *_listChannelResult;
    NSDictionary *_type;
    NSString *_searchKeyWord;
    
    BOOL _searchVideoIsLoaded, _searchAlbumisLoaded, _searchChannelIsLoaded, _searchSuggestionIsLoaded;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *sidebarSearchBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeTypeBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentOption;
@property (weak, nonatomic) IBOutlet UITableView *tblSearchSuggestion;
@property (weak, nonatomic) IBOutlet UITableView *tblSearchVideoResult;
@property (weak, nonatomic) IBOutlet UITableView *tblSearchAlbumResult;
@property (weak, nonatomic) IBOutlet UITableView *tblSearchChannelResult;

@property(nonatomic, assign) NSInteger searchBarState;
@property(nonatomic, assign) NSInteger segmentState;
@property(nonatomic, assign) NSInteger searchVideoResultState;
@property(nonatomic, assign) NSInteger searchAlbumResultState;
@property(nonatomic, assign) NSInteger searchChannelResultState;
@property(nonatomic, assign) NSInteger searchSuggestionState;

@end

@implementation SearchViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self constructUI];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

#pragma mark - GET/SET

- (void) setSegmentState:(NSInteger)segmentState {
    if (self) {
        _segmentState = segmentState;
        [self tableVisibleUpdate];
    }
}

- (void) setSearchSuggestionState:(NSInteger)searchSuggestionState {
    if (self) {
        _searchSuggestionState = searchSuggestionState;
        [self searchSuggestionStateUpdate];
    }
}

#pragma mark - Private Methods

- (void) constructUI {
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if ( revealViewController )
    {
        [self.sidebarSearchBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    // Hidden navigation
    [self.navigationController.navigationBar setHidden:YES];
    
    // Add Delegate for search bar
    [self.searchBar setDelegate:self];
    [self setSearchBarState:0];
    
    // Add Deletate and State for TableView
    
    [self.tblSearchSuggestion setDelegate:self];
    [self.tblSearchSuggestion setDataSource:self];
    _searchSuggestionIsLoaded = NO;
    [self setSearchSuggestionState:SEARCH_SUGGESTION_STATE_HIDDEN];
    
    [self.tblSearchVideoResult setDelegate:self];
    [self.tblSearchVideoResult setDataSource:self];
    _searchVideoIsLoaded = NO;
    
    [self.tblSearchAlbumResult setDelegate:self];
    [self.tblSearchAlbumResult setDataSource:self];
    _searchAlbumisLoaded = NO;
    
    [self.tblSearchChannelResult setDelegate:self];
    [self.tblSearchChannelResult setDataSource:self];
    _searchChannelIsLoaded = NO;
    
    // Add target for segment
    [self setSegmentState:SEGMENT_STATE_VIDEO];
    [self.segmentOption addTarget:self
                           action:@selector(segmentChanged:)
                 forControlEvents:UIControlEventValueChanged];
    
    _type = [NSDictionary dictionaryWithObjects:@[@"video", @"playlist", @"channel"]
                                        forKeys:@[@(SEGMENT_STATE_VIDEO), @(SEGMENT_STATE_ALBUM), @(SEGMENT_STATE_CHANNEL)]];
    
}

-(void) searchSuggestionStateUpdate {
    
    switch (_SEARCH_SUGGESTION_STATE_) {
        case SEARCH_SUGGESTION_STATE_HIDDEN:
            [self.tblSearchSuggestion setHidden:YES];
            break;
        case SEARCH_SUGGESTION_STATE_SHOW:
            [self.tblSearchSuggestion setHidden:NO];
            break;
        case SEARCH_SUGGESTION_STATE_LOADED:
            [self.tblSearchSuggestion setHidden:NO];
            break;
        default:
            break;
    }
}

- (void) tableVisibleUpdate {
    
    switch ([self segmentState]) {
            
        case SEGMENT_STATE_VIDEO:
            
            [[self searchBar] setPlaceholder:@"Search Videos"];
            [[self tblSearchAlbumResult] setHidden:YES];
            [[self tblSearchChannelResult] setHidden:YES];
            
            if ([[self tblSearchVideoResult] isHidden]) {
                [self tblSearchVideoResult].hidden = NO;
            }
            
            if (_searchVideoIsLoaded == NO) {
                if ([self.searchBar.text isEqualToString:@""] == NO) {
                    _listVideoResult = nil;
                    [self.tblSearchVideoResult reloadData];
                    [sYoutubeAPI searchWithKeywork:self.searchBar.text
                                           andType:_TYPE_
                                          andTrack:^(NSArray *tracks) {
                                              _searchVideoIsLoaded = YES;
                                              _listVideoResult = [NSArray arrayWithArray:tracks];
                                              [self.tblSearchVideoResult reloadData];
                                              if ([self.searchBar isFirstResponder]) {
                                                  [self.searchBar resignFirstResponder];
                                              }
                                          }];
                }
                
                break;
            }
            
            break;
        case SEGMENT_STATE_ALBUM:
            
            [[self searchBar] setPlaceholder:@"Search Albums"];
            [[self tblSearchVideoResult] setHidden:YES];
            [[self tblSearchChannelResult] setHidden:YES];
            
            if (self.tblSearchAlbumResult.hidden) {
                self.tblSearchAlbumResult.hidden = NO;
            }
            
            if (_searchAlbumisLoaded == NO) {
                if ([self.searchBar.text isEqualToString:@""] == NO) {
                    _listAlbumResult = nil;
                    [self.tblSearchAlbumResult reloadData];
                    [sYoutubeAPI searchWithKeywork:self.searchBar.text
                                           andType:_TYPE_
                                          andTrack:^(NSArray *tracks) {
                                              _searchAlbumisLoaded = YES;
                                              _listAlbumResult = [NSArray arrayWithArray:tracks];
                                              [self.tblSearchAlbumResult reloadData];
                                              if ([self.searchBar isFirstResponder]) {
                                                  [self.searchBar resignFirstResponder];
                                              }
                                          }];
                }
                
                break;
            }
            
            break;
        case SEGMENT_STATE_CHANNEL:
            
            [[self searchBar] setPlaceholder:@"Search Channels"];
            [[self tblSearchVideoResult] setHidden:YES];
            [[self tblSearchAlbumResult] setHidden:YES];
            
            if (self.tblSearchChannelResult.hidden) {
                self.tblSearchChannelResult.hidden = NO;
            }
            
            if (_searchChannelIsLoaded == NO) {
                if ([self.searchBar.text isEqualToString:@""] == NO) {
                    _listChannelResult = nil;
                    [self.tblSearchChannelResult reloadData];
                    [sYoutubeAPI searchWithKeywork:self.searchBar.text
                                           andType:_TYPE_
                                          andTrack:^(NSArray *tracks) {
                                              _searchChannelIsLoaded = YES;
                                              _listChannelResult = [NSArray arrayWithArray:tracks];
                                              [self.tblSearchChannelResult reloadData];
                                              if ([self.searchBar isFirstResponder]) {
                                                  [self.searchBar resignFirstResponder];
                                              }
                                          }];
                }
                
                break;
            }
            
            break;
        default:
            break;
    }
    
}

#pragma mark - Search Bar Delegate <UISearchBarDelegate>

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([searchBar isEqual:self.searchBar]) {
        [searchBar setShowsCancelButton:YES animated:YES];
        [self setSearchSuggestionState:SEARCH_SUGGESTION_STATE_LOADED];
        return YES;
    }
    return NO;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([searchBar isEqual:self.searchBar]) {
        [searchBar setShowsCancelButton:NO animated:YES];
        [self setSearchSuggestionState:SEARCH_SUGGESTION_STATE_HIDDEN];
        return YES;
    }
    return NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    if ([searchBar isEqual:self.searchBar]) {
        [searchBar setShowsCancelButton:NO animated:YES];
        [self setSearchSuggestionState:SEARCH_SUGGESTION_STATE_HIDDEN];
        [searchBar resignFirstResponder];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([searchBar isEqual:self.searchBar]) {
        
        NSString *searchString = searchBar.text;
        
        if (_searchKeyWord != nil) {
            if ([searchString isEqualToString:_searchKeyWord]) {
                [self setSearchSuggestionState:SEARCH_SUGGESTION_STATE_HIDDEN];
                return;
            }
        }
        
        [[self searchBar] setText:searchString];
        _searchKeyWord = searchString;
        [sYoutubeAPI searchWithKeywork:searchString
                               andType:_TYPE_
                              andTrack:^(NSArray *tracks) {
                                  [self.tblSearchSuggestion setHidden:YES];
                                  if ([self.searchBar isFirstResponder]) {
                                      [self.searchBar resignFirstResponder];
                                  }
                                  [self setSearchSuggestionState:SEARCH_SUGGESTION_STATE_HIDDEN];
                                  switch (_SEGMENT_STATE_) {
                                      case SEGMENT_STATE_VIDEO:
                                          _searchVideoIsLoaded = YES;
                                          _searchAlbumisLoaded = NO;
                                          _searchChannelIsLoaded = NO;
                                          _listVideoResult = [NSArray arrayWithArray:tracks];
                                          [self.tblSearchVideoResult reloadData];
                                          break;
                                      case SEGMENT_STATE_ALBUM:
                                          _searchAlbumisLoaded = YES;
                                          _searchVideoIsLoaded = NO;
                                          _searchChannelIsLoaded = NO;
                                          _listAlbumResult = [NSArray arrayWithArray:tracks];
                                          [self.tblSearchAlbumResult reloadData];
                                          break;
                                      case SEGMENT_STATE_CHANNEL:
                                          _searchChannelIsLoaded = YES;
                                          _searchVideoIsLoaded = NO;
                                          _searchAlbumisLoaded = NO;
                                          _listChannelResult = [NSArray arrayWithArray:tracks];
                                          [self.tblSearchChannelResult reloadData];
                                          break;
                                      default:
                                          break;
                                  }
                                  
                              }];
    }

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchBar isEqual:self.searchBar]) {
        
        _searchVideoIsLoaded = NO;
        _searchAlbumisLoaded = NO;
        _searchChannelIsLoaded = NO;
        
        if ([searchText isEqualToString:@""]) {
            _listSuggestion = nil;
            [self.tblSearchSuggestion reloadData];
        } else {
            [sYoutubeAPI autocompleteSegesstions:searchText
                                   andSuggestion:^(NSMutableArray *ParsingArray) {
                                       _listSuggestion = [NSArray arrayWithArray:ParsingArray];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self.tblSearchSuggestion reloadData];
                                       });
                                   }];
        }
    }
}

#pragma mark - Segment Control

- (void) segmentChanged:(UISegmentedControl *)paramSender {
    if ([paramSender isEqual:self.segmentOption]) {
    
        NSInteger index = [paramSender selectedSegmentIndex];
        [self setSegmentState:index];
        
        if ([self.searchBar isFirstResponder]) {
            [self.searchBar resignFirstResponder];
        }
    }
}

#pragma mark - TableView DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.tblSearchSuggestion] ||
        [tableView isEqual:self.tblSearchVideoResult] ||
        [tableView isEqual:self.tblSearchAlbumResult] ||
        [tableView isEqual:self.tblSearchChannelResult]) {
        
        return 1;
    }
    
    return 0;
}

- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:self.tblSearchSuggestion] &&  section == 0) {
        return [_listSuggestion count];
    }
    
    else if ([tableView isEqual:self.tblSearchVideoResult] && section == 0) {
        return [_listVideoResult count];
    }
    
    else if ([tableView isEqual:self.tblSearchAlbumResult] && section == 0) {
        return [_listAlbumResult count];
    }
    
    else if ([tableView isEqual:self.tblSearchChannelResult] && section == 0) {
        return [_listChannelResult count];
    }
    
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.tblSearchSuggestion]) {
        UITableViewCell *cell = [self.tblSearchSuggestion dequeueReusableCellWithIdentifier:sCellSuggestion
                                                                               forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:sCellSuggestion];
        }
        
        NSString *suggestString = [_listSuggestion objectAtIndex:indexPath.row];
        [cell.textLabel setText:suggestString];
        
        return cell;
        
    }
    
    switch (_SEGMENT_STATE_) {
        case SEGMENT_STATE_VIDEO:
            if ([tableView isEqual:self.tblSearchVideoResult]) {
                
                static NSString *cellId = @"itemCell";
                ItemCell *cell = [self.tblSearchVideoResult dequeueReusableCellWithIdentifier:cellId];
                
                if (!cell) {
                    [tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellReuseIdentifier:cellId];
                    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                }
                
                Video *video = [_listVideoResult objectAtIndex:indexPath.row];
                cell.textLabel.text = video.snippet.title;
                
                return cell;
            }
            break;
        case SEGMENT_STATE_ALBUM:
            if ([tableView isEqual:self.tblSearchAlbumResult]) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sCellAlbumResult
                                                                        forIndexPath:indexPath];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:sCellAlbumResult];
                }
                
                PlaylistSearch *playlist = [_listAlbumResult objectAtIndex:indexPath.row];
                [[cell textLabel] setText:[playlist playlistTitle]];
                
                return cell;
            }
            break;
        case SEGMENT_STATE_CHANNEL:
            if ([tableView isEqual:self.tblSearchChannelResult]) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sCellChannelResult
                                                                        forIndexPath:indexPath];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:sCellChannelResult];
                }
                
                Channel *channel = [_listChannelResult objectAtIndex:indexPath.row];
                [[cell textLabel] setText:[channel title]];
                
                return cell;
            }
            break;
        default:
            break;
    }
    
    return nil;
}

#pragma mark - TableView Delegate

- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:self.tblSearchSuggestion]) {
        
        NSString *searchString = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
        
        if (_searchKeyWord != nil) {
            if ([searchString isEqualToString:_searchKeyWord]) {
                [self setSearchSuggestionState:SEARCH_SUGGESTION_STATE_HIDDEN];
                return;
            }
        }
        
        [[self searchBar] setText:searchString];
        _searchKeyWord = searchString;
        [sYoutubeAPI searchWithKeywork:searchString
                               andType:_TYPE_
                              andTrack:^(NSArray *tracks) {
                                  [self.tblSearchSuggestion setHidden:YES];
                                  if ([self.searchBar isFirstResponder]) {
                                      [self.searchBar resignFirstResponder];
                                  }
                                  [self setSearchSuggestionState:SEARCH_SUGGESTION_STATE_HIDDEN];
                                  switch (_SEGMENT_STATE_) {
                                      case SEGMENT_STATE_VIDEO:
                                          _searchVideoIsLoaded = YES;
                                          _searchAlbumisLoaded = NO;
                                          _searchChannelIsLoaded = NO;
                                          _listVideoResult = [NSArray arrayWithArray:tracks];
                                          [self.tblSearchVideoResult reloadData];
                                          break;
                                      case SEGMENT_STATE_ALBUM:
                                          _searchAlbumisLoaded = YES;
                                          _searchVideoIsLoaded = NO;
                                          _searchChannelIsLoaded = NO;
                                          _listAlbumResult = [NSArray arrayWithArray:tracks];
                                          [self.tblSearchAlbumResult reloadData];
                                          break;
                                      case SEGMENT_STATE_CHANNEL:
                                          _searchChannelIsLoaded = YES;
                                          _searchVideoIsLoaded = NO;
                                          _searchAlbumisLoaded = NO;
                                          _listChannelResult = [NSArray arrayWithArray:tracks];
                                          [self.tblSearchChannelResult reloadData];
                                          break;
                                      default:
                                          break;
                                  }
                                  
                              }];
    }
}

@end
