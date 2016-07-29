/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTLAdSenseUrlChannel.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   AdSense Management API (adsense/v1.4)
// Description:
//   Accesses AdSense publishers' inventory and generates performance reports.
// Documentation:
//   https://developers.google.com/adsense/management/
// Classes:
//   GTLAdSenseUrlChannel (0 custom class methods, 3 custom properties)

#import "GTLAdSenseUrlChannel.h"

// ----------------------------------------------------------------------------
//
//   GTLAdSenseUrlChannel
//

@implementation GTLAdSenseUrlChannel
@dynamic identifier, kind, urlPattern;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map = @{
    @"identifier" : @"id"
  };
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"adsense#urlChannel"];
}

@end
