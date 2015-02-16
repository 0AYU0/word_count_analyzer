module WordCountAnalyzer
  class Slash
    # Rubular: http://rubular.com/r/AqvcH29sgg
    FORWARD_SLASH_REGEX = /(?<=\s)(\S+\/)+\S+|(?<=\A)(\S+\/)+\S+/

    # Rubular: http://rubular.com/r/tuFWtdMs4G
    BACKSLASH_REGEX = /\S+\\\S+/

    attr_reader :string, :processed_string, :date, :xhtml, :hyperlink
    def initialize(string:, **args)
      @string = string
      @date = args[:date] || nil
      @xhtml = args[:xhtml] || nil
      @hyperlink = args[:hyperlink] || nil
      if date.eql?('no_special_treatment')
        if xhtml.eql?('keep')
          if hyperlink.eql?('no_special_treatment') || hyperlink.eql?('split_at_period')
            @processed_string = string
          else
            @processed_string = WordCountAnalyzer::Hyperlink.new(string: string).replace
          end
        else
          if hyperlink.eql?('no_special_treatment') || hyperlink.eql?('split_at_period')
            @processed_string = WordCountAnalyzer::Xhtml.new(string: string).replace
          else
            @processed_string = WordCountAnalyzer::Xhtml.new(string: WordCountAnalyzer::Hyperlink.new(string: string).replace).replace
          end
        end
      else
        if xhtml.eql?('keep')
          if hyperlink.eql?('no_special_treatment') || hyperlink.eql?('split_at_period')
            @processed_string = WordCountAnalyzer::Date.new(string: string).replace
          else
            @processed_string = WordCountAnalyzer::Date.new(string: WordCountAnalyzer::Hyperlink.new(string: string).replace).replace
          end
        else
          if hyperlink.eql?('no_special_treatment') || hyperlink.eql?('split_at_period')
            @processed_string = WordCountAnalyzer::Date.new(string: WordCountAnalyzer::Xhtml.new(string: string).replace).replace
          else
            @processed_string = WordCountAnalyzer::Date.new(string: WordCountAnalyzer::Xhtml.new(string: WordCountAnalyzer::Hyperlink.new(string: string).replace).replace).replace
          end
        end
      end
    end

    def includes_forward_slash?
      !(processed_string !~ FORWARD_SLASH_REGEX)
    end

    def includes_backslash?
      !(processed_string !~ BACKSLASH_REGEX)
    end

    def forward_slash_occurences
      processed_string.scan(FORWARD_SLASH_REGEX).size
    end

    def replace_forward_slashes
      return processed_string if processed_string !~ FORWARD_SLASH_REGEX
      processed_string.gsub!(FORWARD_SLASH_REGEX).each do |match|
        match.split(/\/+/).join(' ')
      end
    end

    def replace_forward_slashes_except_dates
      return processed_string if processed_string !~ FORWARD_SLASH_REGEX
      except_date_string = WordCountAnalyzer::Date.new(string: processed_string).replace_number_only_date
      except_date_string.gsub!(FORWARD_SLASH_REGEX).each do |match|
        match.split(/\/+/).join(' ')
      end
    end

    def backslash_occurences
      processed_string.scan(BACKSLASH_REGEX).size
    end

    def replace_backslashes
      return processed_string if processed_string !~ BACKSLASH_REGEX
      processed_string.gsub!(BACKSLASH_REGEX).each do |match|
        ' word ' * match.split(/\\+/).length
      end
    end
  end
end
