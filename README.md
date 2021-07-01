# liquidity-task-db
Script creating a database for a liquidity-task | PostgreSQL

### db includes:
* data_ads - a list of valid ads (its id, user's id, category and description)
* data_categories - all available categories
* data_segmentation - segmentation for users
* data_replies - all replies to ads stored in db

#### The goal was to obtain a list of users and their liquidity. In order to do so I wrote a function that calculates liquidity for a given user and applied it to all the users stored in db.
