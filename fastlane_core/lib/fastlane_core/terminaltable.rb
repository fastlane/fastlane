require "tty-table"
module FastlaneCore
  class TerminalTable
    attr_accessor :table
    attr_accessor :in_opts
    def initialize(*args, &block)
      options = args.last.respond_to?(:to_hash) ? args.pop : {}
      if options[:headings]
        options[:header] = options[:headings]
      end
      @in_opts = options
      if args.size.nonzero?
        @table = TTY::Table.new(Transformation.extract_tuples(args).merge(options), &block)
      else
        @table = TTY::Table.new(options, &block)
      end
    end
    def to_s 
      table.each_with_index  do | row, index |
        table.row(index) do | row |
          row.to_s
        end
      end 
      return_string = ""
      return_string << table.render(:ascii, multiline: true, resize: true, border: { separator: :each_row})
    end
  end
end
