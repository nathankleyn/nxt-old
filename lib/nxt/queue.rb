module NXT
  module Mixins
    module Queue

      attr_accessor :queue

      def queue_add(command)
        @queue ||= []
        @queue << command
      end

      def queue_clear
        @queue = []
      end

    end
  end
end
