# Inspired by https://github.com/CocoaPods/Core/blob/master/lib/cocoapods-core/podfile/dsl.rb

module IosDeployKit
  module Deliverfile
    class Deliverfile
      module DSL
        def version(foo = nil)
          if block_given?
            foo = yield
          elsif foo
            
          else
            raise "Provide either a value or a blog"
          end

          # TODO: do something with value here
        end

        # private 
        #   def fetch_value_or_block

        #   end
      end
    end
  end
end