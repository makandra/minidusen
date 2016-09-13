describe ActiveRecord::Base do

  describe '.where_like' do

    it 'matches a record if a word appears in any of the given columns' do
      match1 = User.create!(:name => 'word', :city => 'XXXX')
      match2 = User.create!(:name => 'XXXX', :city => 'word')
      no_match = User.create!(:name => 'XXXX', :city => 'XXXX')
      User.where_like([:name, :city] => 'word').to_a.should =~ [match1, match2]
    end

    it 'matches a record if it contains all the given words' do
      match1 = User.create!(:city => 'word1 word2')
      match2 = User.create!(:city => 'word2 word1')
      no_match = User.create!(:city => 'word1')
      User.where_like(:city => ['word1', 'word2']).to_a.should =~ [match1, match2]
    end

    describe 'with :negate option' do

      it 'rejects a record if a word appears in any of the given columns' do
        no_match1 = User.create!(:name => 'word', :city => 'XXXX')
        no_match2 = User.create!(:name => 'XXXX', :city => 'word')
        match = User.create!(:name => 'XXXX', :city => 'XXXX')
        User.where_like({ [:name, :city] => 'word' }, :negate => true).to_a.should =~ [match]
      end

      it 'rejects a record if it matches at least one of the given words' do
        no_match1 = User.create!(:city => 'word1')
        no_match2 = User.create!(:city => 'word2')
        match = User.create!(:city => 'word3')
        User.where_like({ :city => ['word1', 'word2'] }, :negate => true).to_a.should =~ [match]
      end

      it "doesn't match NULL values" do
        no_match = User.create!(:city => nil)
        match = User.create!(:city => 'word3')
        User.where_like({ :city => ['word1'] }, :negate => true).to_a.should =~ [match]
      end

    end

  end

end