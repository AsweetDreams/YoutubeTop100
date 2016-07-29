//
//  Constant.h
//  Project_Techkid_Gen2
//
//  Created by Pham Anh on 3/27/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

//#define kYoutubeAPIkey     @"729917611598-hjt8914q08glksj7e869ohrkrkb8c2jo.apps.googleusercontent.com"
#define kYoutubeAPIkey     @"AIzaSyDxiDmfSkdQ463GwZD9EN_b06c_O6gkWT0"

#define kItunesExploreUrl @"https://itunes.apple.com/%@/rss/%@/offset=10/limit=100/%@json"
#define kURLExplodeITunes  @"https://itunes.apple.com/%@/rss/topsongs/%@limit=100/json"
#define kURLExplodeAlbumITunes  @"https://itunes.apple.com/%@/rss/topalbums/%@limit=100/json"

#define kURLExploreListSongFromAlbumITunes @"https://itunes.apple.com/lookup?id=%@&entity=song"

#define ksuggestionVideoURL @"http://suggestqueries.google.com/complete/search?output=youtube&ds=yt&alt=json&q=%@"

// For menu

#define kMenuItems @[@"appName",@"top100",@"search",@"history",@"playlists",@"setting"]


#endif /* Constant_h */
