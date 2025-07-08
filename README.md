# IP Activities Assignment

This is a take-home assignment for evaluating senior Ruby on Rails developers. The assignment focuses on IP activities functionality.

## Background

The application tracks IP activities for users and their trading accounts. Each IP activity has an activity type (trade, login, kyc) and is associated with either a user or a trading account.

The database contains 100M records, so performance optimization is crucial.

## Assignment

### Task 1: Optimize IpActivity Scopes and Implement Smart Limiting

**Context:**
- User has related TradingAccount model
- Both have related IpActivity model that logs user activity
- Each IpActivity has its own type:
  - `kyc` - IP addresses from which user passes verification, no more than 10 records
  - `login` - IP addresses from which user logs in, these activities are tied to user, no more than 1000 records
  - `trade` - activities that log IP addresses of client trading operations from different platforms, can be 1000-10000 records

**Task:**
Display in the index controller action for further serialization and map rendering the latest user activity by date. Regardless of date, ensure that `kyc` and `login` types are always displayed (no more than 1000 per each type) and the remaining slots up to a total limit of 3000 are filled with `trade` activities.

**Example:**
If a client has IP activities with types: kyc - 1, login - 500, trade - 2000
Should output: 1 + 500 + 1000 = 1501 IpActivity records

**Requirements:**
1. Optimize the existing scopes in the `IpActivity` model
2. Implement smart limiting logic that prioritizes `kyc` and `login` activities
3. Fill remaining slots with `trade` activities up to total limit of 3000
4. Consider database performance with 100M records
5. Maintain existing API functionality

**Current scopes to optimize:**
```ruby
  scope :for_user, lambda { |user|
    where(user:).includes(:user, :trading_account, :ip_address_record)
                .or(where(trading_account_login: user.trading_accounts.select(:login)))
  }
  scope :recent_n_per_activity_type, lambda { |limit|
    query = <<-SQL.squish
      SELECT activity_limited.id
      FROM (SELECT DISTINCT activity_type FROM ip_activities) activity_groups
      JOIN LATERAL (
        SELECT * FROM ip_activities activity_all
        WHERE activity_all.activity_type = activity_groups.activity_type
        ORDER BY activity_all.created_at DESC
        LIMIT :limit
      ) activity_limited ON true
    SQL

    where("ip_activities.id IN (#{ApplicationRecord.sanitize_sql([query, { limit: }])})")
  }
```

### Task 2: Design Reusable Filter Component Architecture

**Context:**
The current implementation lacks a filtering component. The task is to design the architecture of a reusable filter component that can accept parameters, save them to the database, and be universal enough to be applied to filtering users, trading_accounts, or other models with their own parameter sets.

**Requirements:**
1. Design a universal filter model that can be applied to different entities (users, trading_accounts, ip_activities)
2. Filter should work in both `index` and `filter_metadata` endpoints
3. Parameters should be persistable in the database
4. Component should be reusable across different controllers and models
5. Support different filter types (date ranges, enums, text search, etc.)

**Deliverables:**
Choose one of the implementation options:
- **Option A:** Complete code implementation with all necessary models, controllers, and services
- **Option B:** Detailed architecture description with schema design, usage examples, and implementation sketches

**Consider:**
- How to handle different parameter types for different models
- Database schema design for storing filter configurations
- API design for filter endpoints
- Performance implications
- Code reusability and maintainability

## Getting Started

1. Clone the repository
2. Run `bundle install`
3. Set up the database: `rails db:create db:migrate db:seed`
4. Start the server: `rails s`

## API Endpoints

- `GET /api/users/:user_id/ip_activities` - Returns IP activities for a user
- `GET /api/users/:user_id/ip_activities/filter_metadata` - Returns metadata for filtering IP activities

## Testing

Run the tests with:

```
bin/rspec
```

## Submission

Please provide your optimized solution along with an explanation of your approach and any trade-offs you made.
