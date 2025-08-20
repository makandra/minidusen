<p>
  <a href="https://makandra.de/">
    <picture>
      <source media="(prefers-color-scheme: light)" srcset="media/makandra-with-bottom-margin.light.svg">
      <source media="(prefers-color-scheme: dark)" srcset="media/makandra-with-bottom-margin.dark.svg">
      <img align="right" width="25%" alt="makandra" src="media/makandra-with-bottom-margin.light.svg">
    </picture>
  </a>

  <picture>
    <source media="(prefers-color-scheme: light)" srcset="media/logo.light.shapes.svg">
    <source media="(prefers-color-scheme: dark)" srcset="media/logo.dark.shapes.svg">
    <img width="210" alt="Minidusen" role="heading" aria-level="1" src="media/logo.light.shapes.svg">
  </picture>
</p>

[![Tests](https://github.com/makandra/minidusen/workflows/Tests/badge.svg)](https://github.com/makandra/minidusen/actions)

Low-tech search solution for ActiveRecord with MySQL or PostgreSQL
------------------------------------------------------------------

Minidusen lets you filter ActiveRecord models with a single query string.
It works with your existing MySQL or PostgreSQL schema by mostly relying on simple `LIKE` queries. No additional indexes, tables or indexing databases are required.

This makes Minidusen a quick way to implement find-as-you-type filters for index views:

![A list of records filtered by a query](https://raw.githubusercontent.com/makandra/minidusen/main/doc/filtered_index_view.cropped.png)


### Supported queries

Minidusen accepts a single, Google-like query string and converts it into `WHERE` conditions for [an ActiveRecord scope](http://guides.rubyonrails.org/active_record_querying.html#conditions).

The following type of queries are supported:

- `foo` (case-insensitive search for `foo` in developer-defined columns)
- `foo bar` (rows must include both `foo` and `bar`)
- `"foo bar"` (rows must include the phrase `"foo bar"`)
- `-bar` (rows must not include the word `bar`)
- `filetype:pdf` (developer-defined filter for file type)
- `some words 'a phrase' filetype:pdf -excluded -'excluded  phrase' -filetype:pdf` (combination of the above)


### Limitations

Since Minidusen doesn't use an index, it scales linearly with the amount of of text that needs to be searched. Yet `LIKE` queries are pretty fast and we have found this low-tech approach to scale well for many thousand records.

It's probably not a good idea to use Minidusen for hundreds of thousands of records, or for very long text columns. For this we recommend to use PostgreSQL with [pg_search](https://github.com/Casecommons/pg_search) or full-text databases like [Solr](https://github.com/sunspot/sunspot).

Another limitation of Minidusen is that it only *filters*, but does not *rank*. A record either matches or not. Minidusen won't tell you if one record matches *better* than another record.


Installation
------------

In your `Gemfile` say:

```ruby
gem 'minidusen'
```

Now run `bundle install` and restart your server.


Basic Usage
-----------

Our example will be a simple address book:

```ruby
class Contact < ApplicationRecord
  validates_presence_of :name, :street, :city, :email
end
```

We create a new class `ContactFilter` that will describe the searchable columns:

```ruby
class ContactFilter
  include Minidusen::Filter

  filter :text do |scope, phrases|
    columns = [:name, :email]
    scope.where_like(columns => phrases)
  end
end
```

We can now use `ContactFilter` to filter a scope of `Contact` records:

```ruby
# We start by building a scope of all contacts.
# No SQL query is made.
all_contacts = Contact.all
# => ActiveRecord::Relation

# Now we filter the scope to only contain contacts with "gmail" in either :name or :email column.
# Again, no SQL query is made.
gmail_contacts = ContactFilter.new.filter(all_contacts, 'gmail')
# => ActiveRecord::Relation

# Inspect the filtered scope.
gmail_contacts.to_sql
# => "SELECT * FROM contacts WHERE name LIKE '%gmail%' OR email LIKE '%gmail%'"

# Finally we load the scope to produce an array of Contact records.
gmail_contacts.to_a
# => Array
```

### Filtering scopes with existing conditions

Note that you can also pass a scope with existing conditions to `ContactFilter#filter`. The returned scope will contain both the existing conditions and the conditions from the filter:

```ruby
published_contacts = Contact.where(published: true)
# => ActiveRecord::Relation

published_contacts.to_sql
# => "SELECT * FROM contacts WHERE (published = 1)"

gmail_contacts = ContactFilter.new.filter(published_contacts, 'gmail')
# => ActiveRecord::Relation

gmail_contacts.to_sql
# => "SELECT * FROM contacts WHERE (published = 1) AND (name LIKE '%gmail%' OR email LIKE '%gmail%')"
```

### How `where_like` works

The example above uses `where_like`. You can call `where_like` on any scope to produce a new scope where the given array of column names must contain all of the given phrases.

Let's say we call `ContactFilter.new.filter(Contact.published, 'foo "bar baz" bam')`. This will call the block `filter :text do |scope, phrases|` with the following arguments:

```ruby
scope == Contact.published
phrases == ['foo', 'bar baz', 'bam']
```

The scope `scope.where_like(columns => phrases)` will now represent the following SQL query:

```ruby
SELECT * FROM contacts
WHERE (name LIKE "%foo%" OR email LIKE "%foo") AND (email LIKE "%foo%" OR email LIKE "%foo")
```

You can also use `where_like` to find all the records *not* matching some phrases, using the `:negate` option:

```ruby
Contact.where_like(name: 'foo', negate: true)
```

Filtering associated records
----------------------------

Minidusen lets you find text in associated records.

Assume the following model where a `Contact` record may be associated with a `Group` record:

```ruby
class Contact < ApplicationRecord
  belongs_to :group

  validates_presence_of :name, :street, :city, :email
end

class Group < ApplicationRecord
  has_many :contacts

  validates_presence_of :name
end
```

We can filter contacts by their group name by joining the `groups` table and filtering on a joined column.
Note how the joined column is qualified as `groups.name` (rather than just `name`):

```ruby
class ContactFilter
  include Minidusen::Filter

  filter :text do |scope, phrases|
    columns = [:name, :email, 'groups.name']
    scope.includes(:group).where_like(columns => phrases)
  end
end
```



Supporting qualified field syntax
---------------------------------

Google supports queries like `filetype:pdf` that filters records by some criteria without performing a full text search. Minidusen gives you a simple way to support such search syntax.

Let's support a query like `email:foo@bar.com` to explictly search for a contact's email address, without filtering against other columns.

We can learn this syntax by adding a `filter:email` instruction
to our `ContactFilter` class:

```ruby
class ContactFilter
  include Minidusen::Filter

  filter :email do |scope, email|
    scope.where(email: email)
  end

  filter :text do |scope, phrases|
    columns = [:name, :email]
    scope.where_like(columns => phrases)
  end

end
```

We can now explicitly search for a user's e-mail address:

```ruby
ContactFilter.new.filter(Contact, 'email:foo@bar.com').to_sql
# => "SELECT * FROM contacts WHERE email='foo@bar.com'"
```

Filter aliases
--------------

You can define aliases for the same filter by passing multiple field names to a single `filter` call:

```ruby
class ContactFilter
  include Minidusen::Filter

  filter :email, :mail, :contact do |scope, email|
    scope.where(email: email)
  end
end
```

Now you can search using any of the defined aliases:

```ruby
ContactFilter.new.filter(Contact, 'email:foo@bar.com').to_sql
# => "SELECT * FROM contacts WHERE email='foo@bar.com'"

ContactFilter.new.filter(Contact, 'mail:foo@bar.com').to_sql
# => "SELECT * FROM contacts WHERE email='foo@bar.com'"

ContactFilter.new.filter(Contact, 'contact:foo@bar.com').to_sql
# => "SELECT * FROM contacts WHERE email='foo@bar.com'"
```

This feature is useful when you want to provide multiple intuitive ways for users to search the same field.

### Caveat

If you search for a phrase containing a colon (e.g. `deploy:rollback`), Minidusen will mistake the first part as a – nonexistent – qualifier and return an empty set.

To prevent that, search for a phrase:

    "deploy:rollback"


Supported Rails versions
------------------------

Minidusen is tested on:

- Rails 6.1
- Rails 7.0
- Rails 7.1
- Rails 7.2
- MySQL 5.6
- PostgreSQL

If you need support for platforms not listed above, please submit a PR!


Development
-----------

- There are tests in `spec`. We only accept PRs with tests.
- We currently develop using the Ruby version in `.ruby-version`. It is required to change the Ruby Version to cover all Rails version or just use Gitlab CI.
- Put your database credentials into `spec/support/database.yml`. There's a `database.sample.yml` you can use as a template.
- Create a database `minidusen_test` in both MySQL and PostgreSQL.
- There are gem bundles in the project root for each combination of ActiveRecord version and database type that we support.
- You can bundle all test applications by saying `bundle exec rake matrix:install`
- You can run specs from the project root by saying `bundle exec rake matrix:spec`. This will run all gemfiles compatible with your current Ruby.

If you would like to contribute:

- Fork the repository.
- Push your changes **with passing specs**.
- Send me a pull request.

Note that we're very eager to keep this gem lightweight. If you're unsure whether a change would make it into the gem, [open an issue](https://github.com/makandra/minidusen/issues/new).


Credits
-------

Henning Koch from [makandra](http://makandra.com/)
