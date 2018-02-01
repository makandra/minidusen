describe Minidusen::Parser do

  describe '.parse' do

    describe 'when called with a String' do

      it 'parses the given string into tokens' do
        query = Minidusen::Parser.parse('fieldname:fieldvalue word "a phrase" "deploy:rollback" -"db:seed"')
        query.size.should == 5
        query[0].field.should == 'fieldname'
        query[0].value.should == 'fieldvalue'
        query[0].exclude.should == false
        query[1].field.should == 'text'
        query[1].value.should == 'word'
        query[1].exclude.should == false
        query[2].field.should == 'text'
        query[2].value.should == 'a phrase'
        query[2].exclude.should == false
        query[3].field.should == 'text'
        query[3].value.should == 'deploy:rollback'
        query[3].exclude.should == false
        query[4].field.should == 'text'
        query[4].value.should == 'db:seed'
        query[4].exclude.should == true
      end

      it 'should parse field tokens first, because they usually give maximum filtering at little cost' do
        query = Minidusen::Parser.parse('word1 field1:field1-value word2 field2:field2-value "search:word"')
        query.collect(&:value).should == ['field1-value', 'field2-value', 'word1', 'word2', 'search:word']
      end

      it 'should not consider the dash to be a word boundary' do
        query = Minidusen::Parser.parse('Baden-Baden')
        query.collect(&:value).should == ['Baden-Baden']
      end

      it 'should parse umlauts and accents' do
        query = Minidusen::Parser.parse('field:åöÙÔøüéíÁ "ÄüÊçñÆ ððÿáÒÉ" pulvérisateur pędzić')
        query.collect(&:value).should == ['åöÙÔøüéíÁ', 'ÄüÊçñÆ ððÿáÒÉ', 'pulvérisateur', 'pędzić']
      end

      it 'should allow to search for a phrase containing a colon' do
        query = Minidusen::Parser.parse('"deploy:rollback"')
        query.size.should == 1
        query[0].field.should == 'text'
        query[0].value.should == 'deploy:rollback'
        query[0].exclude.should == false
      end

      it 'should parse a field token which is at the beginning of the search string' do
        query = Minidusen::Parser.parse('filetype:pdf word')
        query.size.should == 2
        query[0].field.should == 'filetype'
        query[0].value.should == 'pdf'
        query[0].exclude.should == false
      end

      it 'should parse an excluded field token which is at the beginning of the search string' do
        query = Minidusen::Parser.parse('-filetype:docx word')
        query.size.should == 2
        query[0].field.should == 'filetype'
        query[0].value.should == 'docx'
        query[0].exclude.should == true
      end

    end

    describe 'when called with a Query' do

      it 'returns the query' do
        passed_query = Minidusen::Query.new
        parsed_query = Minidusen::Parser.parse(passed_query)
        parsed_query.should == passed_query
      end

    end

    describe 'when called with an array of strings' do

      it 'returns a query of text tokens' do
        query = Minidusen::Parser.parse(['word', 'a phrase'])
        query.size.should == 2
        query[0].field.should == 'text'
        query[0].value.should == 'word'
        query[1].field.should == 'text'
        query[1].value.should == 'a phrase'
      end

    end

  end

end
