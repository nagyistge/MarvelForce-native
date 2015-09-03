/*
 Copyright (c) 2013, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Created by Bharath Hariharan on 6/11/13.
 */

#import "SmartStoreInterface.h"
#import <SalesforceSDKCore/SFSmartStore.h>
#import <SalesforceSDKCore/SFSoupIndex.h>
#import <SalesforceSDKCore/SFQuerySpec.h>
#import <SalesforceCommonUtils/NSDictionary+SFAdditions.h>

NSString* const kContactSoupName = @"Contact";
NSString* const kAccountSoupName = @"Account";
NSString* const kOpportunitySoupName = @"Opportunity";

NSString* const kAllContactsQuery = @"SELECT {Contact:Name}, {Contact:Id} FROM {Contact}";
NSString* const kAllAccountsQuery = @"SELECT {Account:Name}, {Account:Id}, {Account:OwnerId} FROM {Account}";
NSString* const kAllOpportunitiesQuery = @"SELECT {Opportunity:Name}, {Opportunity:Id}, {Opportunity:AccountId}, {Opportunity:OwnerId}, {Opportunity:Amount} FROM {Opportunity}";

NSString* const kAggregateQueryStr = @"SELECT {Account:Name}, COUNT({Opportunity:Name}), SUM({Opportunity:Amount}), AVG({Opportunity:Amount}), {Account:Id}, {Opportunity:AccountId} FROM {Account}, {Opportunity} WHERE {Account:Id} = {Opportunity:AccountId} GROUP BY {Account:Name}";

@implementation SmartStoreInterface : NSObject

@synthesize store = _store;

- (id)init
{
    self = [super init];
    if (nil != self)  {
        
    }
    return self;
}

- (SFSmartStore *)store
{
    return [SFSmartStore sharedStoreWithName:kDefaultSmartStoreName];
}
- (void)createContactSoup
{
    if (![self.store soupExists:kContactSoupName]) {
        NSArray *keys = @[@"path", @"type"];
        
        NSArray *nameValues = @[@"Name", kSoupIndexTypeString];
        NSDictionary *nameDictionary = [NSDictionary dictionaryWithObjects:nameValues forKeys:keys];
        NSArray *idValues = @[@"Id", kSoupIndexTypeString];
        NSDictionary *idDictionary = [NSDictionary dictionaryWithObjects:idValues forKeys:keys];
        NSArray *contactIndexSpecs = [SFSoupIndex asArraySoupIndexes:@[nameDictionary, idDictionary]];
        [self.store registerSoup:kContactSoupName withIndexSpecs:contactIndexSpecs];
    }
}

- (void)createAccountsSoup
{
    if (![self.store soupExists:kAccountSoupName]) {
        NSArray *keys = @[@"path", @"type"];
        NSArray *nameValues = @[@"Name", kSoupIndexTypeString];
        NSDictionary *nameDictionary = [NSDictionary dictionaryWithObjects:nameValues forKeys:keys];
        NSArray *idValues = @[@"Id", kSoupIndexTypeString];
        NSDictionary *idDictionary = [NSDictionary dictionaryWithObjects:idValues forKeys:keys];
        NSArray *ownerIdValues = @[@"OwnerId", kSoupIndexTypeString];
        NSDictionary *ownerIdDictionary = [NSDictionary dictionaryWithObjects:ownerIdValues forKeys:keys];
        NSArray *accountIndexSpecs = [SFSoupIndex asArraySoupIndexes:@[nameDictionary, idDictionary, ownerIdDictionary]];
        [self.store registerSoup:kAccountSoupName withIndexSpecs:accountIndexSpecs];
    }
}

- (void)createOpportunitiesSoup
{
    if (![self.store soupExists:kOpportunitySoupName]) {
        NSArray *keys = @[@"path", @"type"];
        NSArray *nameValues = @[@"Name", kSoupIndexTypeString];
        NSDictionary *nameDictionary = [NSDictionary dictionaryWithObjects:nameValues forKeys:keys];
        NSArray *idValues = @[@"Id", kSoupIndexTypeString];
        NSDictionary *idDictionary = [NSDictionary dictionaryWithObjects:idValues forKeys:keys];
        NSArray *accountIdValues = @[@"AccountId", kSoupIndexTypeString];
        NSDictionary *accountIdDictionary = [NSDictionary dictionaryWithObjects:accountIdValues forKeys:keys];
        NSArray *ownerIdValues = @[@"OwnerId", kSoupIndexTypeString];
        NSDictionary *ownerIdDictionary = [NSDictionary dictionaryWithObjects:ownerIdValues forKeys:keys];
        NSArray *amountValues = @[@"Amount", kSoupIndexTypeFloating];
        NSDictionary *amountDictionary = [NSDictionary dictionaryWithObjects:amountValues forKeys:keys];
        NSArray *opportunityIndexSpecs = [SFSoupIndex asArraySoupIndexes:@[nameDictionary, idDictionary, accountIdDictionary, ownerIdDictionary, amountDictionary]];
        [self.store registerSoup:kOpportunitySoupName withIndexSpecs:opportunityIndexSpecs];
    }
}

- (void)deleteAccountsSoup
{
    if ([self.store soupExists:kAccountSoupName]) {
        [self.store removeSoup:kAccountSoupName];
    }
}

- (void)deleteOpportunitiesSoup
{
    if ([self.store soupExists:kOpportunitySoupName]) {
        [self.store removeSoup:kOpportunitySoupName];
    }
}
- (void)insertContacts:(NSArray*)contacts
{
    if (nil != contacts) {
        for (int i = 0; i < contacts.count; i++) {
            [self insertContact:contacts[i]];
        }
    }
}

- (void)insertAccounts:(NSArray*)accounts
{
    if (nil != accounts) {
        for (int i = 0; i < accounts.count; i++) {
            [self insertAccount:accounts[i]];
        }
    }
}

- (void)insertOpportunities:(NSArray*)opportunities
{
    if (nil != opportunities) {
        for (int i = 0; i < opportunities.count; i++) {
            [self insertOpportunity:opportunities[i]];
        }
    }
}

- (void)insertContact:(NSDictionary*)contact
{
    if (nil != contact) {
        [self.store upsertEntries:@[contact] toSoup:kContactSoupName];
    }
}

- (void)insertAccount:(NSDictionary*)account
{
    if (nil != account) {
        [self.store upsertEntries:@[account] toSoup:kAccountSoupName];
    }
}

- (void)insertOpportunity:(NSDictionary*)opportunity
{
    if (nil != opportunity) {

        /*
         * SmartStore doesn't currently support default values
         * for indexed columns (0 for 'integer' or 'floating',
         * for instance. It stores the data as is. Hence, we need
         * to check the values for 'Amount' and replace 'null'
         * with '0', for aggregate queries such as 'sum' and
         * 'avg' to work properly.
         */
        NSMutableDictionary *mutableOpportunity = [NSMutableDictionary dictionaryWithDictionary:opportunity];
        double amount = 0;
        if (![mutableOpportunity nonNullObjectForKey:@"Amount"]) {
            mutableOpportunity[@"Amount"] = @(amount);
        }
        [self.store upsertEntries:@[mutableOpportunity] toSoup:kOpportunitySoupName];
    }
}

- (NSArray*)getAccounts
{
    return [self query:kAllAccountsQuery];
}

- (NSArray*)getOpportunities
{
    return [self query:kAllOpportunitiesQuery];
}

- (NSArray*)query:(NSString*)queryString
{
    SFQuerySpec *querySpec = [SFQuerySpec newSmartQuerySpec:queryString withPageSize:10];
    int count = (int)[self.store countWithQuerySpec:querySpec error:nil];
    querySpec = [SFQuerySpec newSmartQuerySpec:queryString withPageSize:count];
    return [self.store queryWithQuerySpec:querySpec pageIndex:0 error:nil];
}

@end