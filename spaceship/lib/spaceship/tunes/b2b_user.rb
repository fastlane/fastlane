require_relative 'tunes_base'
module Spaceship
  module Tunes
    class B2bUser < TunesBase
      # @return (Bool) add the user to b2b list
      attr_accessor :add

      # @return (Bool) delete the user to b2b list
      attr_accessor :delete

      # @return (String) b2b username
      attr_accessor :ds_username

      attr_mapping(
        'value.add' => :add,
        'value.delete' => :delete,
        'value.dsUsername' => :ds_username
      )

      def self.from_username(username)
        self.new({ 'value' => { 'add' => true, 'delete' => false, 'dsUsername' => username } })
      end
    end
  end
end
