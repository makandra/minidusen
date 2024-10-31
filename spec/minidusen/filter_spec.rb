describe Minidusen::Filter do

  let :user_filter do
    UserFilter.new
  end

  let :recipe_filter do
    RecipeFilter.new
  end

  describe '#filter' do

    it 'should find records by given words' do
      match = User.create!(:name => 'Abraham')
      no_match = User.create!(:name => 'Elizabath')
      user_filter.filter(User, 'Abraham').to_a.should == [match]
    end

    it 'should make a case-insensitive search' do
      match = User.create!(:name => 'Abraham')
      no_match = User.create!(:name => 'Elizabath')
      user_filter.filter(User, 'aBrAhAm').to_a.should == [match]
    end

    it 'should not find stale text after fields were updated (bugfix)' do
      match = User.create!(:name => 'Abraham')
      no_match = User.create!(:name => 'Elizabath')
      match.name = 'Johnny'
      match.save!

      user_filter.filter(User, 'Abraham').to_a.should be_empty
      user_filter.filter(User, 'Johnny').to_a.should == [match]
    end

    it 'should AND multiple words' do
      match = User.create!(:name => 'Abraham Lincoln')
      no_match = User.create!(:name => 'Abraham')
      user_filter.filter(User, 'Abraham Lincoln').to_a.should == [match]
    end

    it 'should find records by phrases' do
      match = User.create!(:name => 'Abraham Lincoln')
      no_match = User.create!(:name => 'Abraham John Lincoln')
      user_filter.filter(User, '"Abraham Lincoln"').to_a.should == [match]
    end

    it 'should find records by qualified fields' do
      match = User.create!(:name => 'foo@bar.com', :email => 'foo@bar.com')
      no_match = User.create!(:name => 'foo@bar.com', :email => 'bam@baz.com')
      user_filter.filter(User, 'email:foo@bar.com').to_a.should == [match]
    end

    it 'should find no records if a nonexistent qualifier is used' do
      User.create!(:name => 'someuser', :email => 'foo@bar.com')
      user_filter.filter(User, 'nonexistent_qualifier:someuser email:foo@bar.com').to_a.should == []
    end

    it 'should allow phrases as values for qualified field queries' do
      match = User.create!(:name => 'Foo Bar', :city => 'Foo Bar')
      no_match = User.create!(:name => 'Foo Bar', :city => 'Bar Foo')
      user_filter.filter(User, 'city:"Foo Bar"').to_a.should == [match]
    end

    it 'should allow to mix multiple types of tokens in a single query' do
      match = User.create!(:name => 'Abraham', :city => 'Foohausen')
      no_match = User.create!(:name => 'Abraham', :city => 'Barhausen')
      user_filter.filter(User, 'Foo city:Foohausen').to_a.should == [match]
    end

    it 'should not find records from another model' do
      match = User.create!(:name => 'Abraham')
      Recipe.create!(:name => 'Abraham')
      user_filter.filter(User, 'Abraham').to_a.should == [match]
    end

    it 'should find words where one letter is separated from other letters by a period' do
      match = User.create!(:name => 'E.ONNNEN')
      user_filter.filter(User, 'E.ONNNEN').to_a.should == [match]
    end

    it 'should find words where one letter is separated from other letters by a semicolon' do
      match = User.create!(:name => 'E;ONNNEN')
      user_filter.filter(User, 'E;ONNNEN')
      user_filter.filter(User, 'E;ONNNEN').to_a.should == [match]
    end

    it 'should distinguish between "Baden" and "Baden-Baden" (bugfix)' do
      match = User.create!(:city => 'Baden-Baden')
      no_match = User.create!(:city => 'Baden')
      user_filter.filter(User, 'Baden-Baden').to_a.should == [match]
    end

    it 'should handle umlauts and special characters' do
      match = User.create!(:city => 'púlvérìsätëûr')
      user_filter.filter(User, 'púlvérìsätëûr').to_a.should == [match]
    end

    context 'with excludes' do

      it 'should exclude words with prefix - (minus)' do
        match = User.create!(:name => 'Sunny Flower')
        no_match = User.create!(:name => 'Sunny Power')
        no_match2 = User.create!(:name => 'Absolutly no match')
        user_filter.filter(User, 'Sunny -Power').to_a.should == [match]
      end

      it 'should exclude phrases with prefix - (minus)' do
        match = User.create!(:name => 'Buch Tastatur Schreibtisch')
        no_match = User.create!(:name => 'Buch Schreibtisch Tastatur')
        no_match2 = User.create!(:name => 'Absolutly no match')
        user_filter.filter(User, 'Buch -"Schreibtisch Tastatur"').to_a.should == [match]
      end

      it 'should exclude qualified fields with prefix - (minus)' do
        match = User.create!(:name => 'Abraham', :city => 'Foohausen')
        no_match = User.create!(:name => 'Abraham', :city => 'Barhausen')
        no_match2 = User.create!(:name => 'Absolutly no match')
        user_filter.filter(User, 'Abraham -city:Barhausen').to_a.should == [match]
      end

      it 'should work if the query only contains excluded words' do
        match = User.create!(:name => 'Sunny Flower')
        no_match = User.create!(:name => 'Sunny Power')
        user_filter.filter(User, '-Power').to_a.should == [match]
      end

      it 'should work if the query only contains excluded phrases' do
        match = User.create!(:name => 'Buch Tastatur Schreibtisch')
        no_match = User.create!(:name => 'Buch Schreibtisch Tastatur')
        user_filter.filter(User, '-"Schreibtisch Tastatur"').to_a.should == [match]
      end

      it 'should work if the query only contains excluded qualified fields' do
        match = User.create!(:name => 'Abraham', :city => 'Foohausen')
        no_match = User.create!(:name => 'Abraham', :city => 'Barhausen')
        user_filter.filter(User, '-city:Barhausen').to_a.should == [match]
      end

      it 'respects an existing scope chain when there are only excluded tokens (bugfix)' do
        match = User.create!(:name => 'Abraham', :city => 'Foohausen')
        no_match = User.create!(:name => 'Abraham', :city => 'Barhausen')
        also_no_match = User.create!(:name => 'Bebraham', :city => 'Foohausen')
        user_scope = User.scoped(:conditions => { :name => 'Abraham' })
        user_filter.filter(user_scope, '-Barhausen').to_a.should == [match]
      end

      it 'should work if there are fields contained in the search that are NULL' do
        match = User.create!(:name => 'Sunny Flower', :city => nil, :email => nil)
        no_match = User.create!(:name => 'Sunny Power', :city => nil, :email => nil)
        no_match2 = User.create!(:name => 'Absolutly no match')
        user_filter.filter(User, 'Sunny -Power').to_a.should == [match]
      end

      it 'should work if search_by contains a join (bugfix)' do
        category1 = Recipe::Category.create!(:name => 'Rice')
        category2 = Recipe::Category.create!(:name => 'Barbecue')
        match = Recipe.create!(:name => 'Martini Chicken', :category => category1)
        no_match = Recipe.create!(:name => 'Barbecue Chicken', :category => category2)
        recipe_filter.filter(Recipe, 'Chicken -category:Barbecue').to_a.should == [match]
      end

      it 'should work when search_by uses SQL-Regexes which need to be "and"ed together by syntax#build_exclude_scope (bugfix)' do
        match = User.create!(:name => 'Sunny Flower', :city => "Flower")
        no_match = User.create!(:name => 'Sunny Power', :city => "Power")
        user_filter.filter(User, '-name_and_city_regex:Power').to_a.should == [match]
      end

      it 'can be filtered twice' do
        match = User.create!(:name => 'Sunny Flower', :city => "Flower")
        no_match = User.create!(:name => 'Sunny Power', :city => "Power")
        also_no_match = User.create!(:name => 'Sunny Forever', :city => "Forever")
        first_result = user_filter.filter(User, '-name_and_city_regex:Power')
        user_filter.filter(first_result, '-name_and_city_regex:Forever').to_a.should == [match]
      end

    end

    context 'when the given query is blank' do

      it 'returns all records' do
        match = User.create!
        user_filter.filter(User, '').scoped.to_a.should == [match]
      end

      it 'respects an existing scope chain' do
        match = User.create!(:name => 'Abraham')
        no_match = User.create!(:name => 'Elizabath')
        scope = User.scoped(:conditions => { :name => 'Abraham' })
        user_filter.filter(scope, '').scoped.to_a.should == [match]
      end

    end

    it 'runs filter in the instance context' do
      filter_class = Class.new do
        include Minidusen::Filter

        def columns
          [:name, :email, :city]
        end

        filter :text do |scope, phrases|
          scope.report_instance(self)
          scope.where_like(columns => phrases)
        end
      end
      filter_instance = filter_class.new

      match = User.create!(:name => 'Abraham')
      no_match = User.create!(:name => 'Elizabath')
      expect(User).to receive(:report_instance).with(filter_instance)
      filter_instance.filter(User, 'Abra').to_a.should == [match]
    end

  end

  describe '#minidusen_syntax' do

    it "should return the model's syntax definition" do
      syntax = UserFilter.send(:minidusen_syntax)
      syntax.should be_a(Minidusen::Syntax)
      syntax.fields.keys.should =~ ['text', 'email', 'city', 'role', 'name_and_city_regex']
    end

  end

end
