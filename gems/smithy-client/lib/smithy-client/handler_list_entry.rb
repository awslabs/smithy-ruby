# frozen_string_literal: true

module Smithy
  module Client
    # A container for an un-constructed handler. A handler entry has the
    # handler class, and information about handler priority/order.
    #
    # This class is an implementation detail of the {HandlerList} class.
    # Do not rely on public interfaces of this class.
    class HandlerListEntry
      # @api private
      STEPS = {
        initialize: 400,
        validate: 300,
        build: 200,
        sign: 100,
        send: 0
      }.freeze

      # @option options [Class<Handler>] :handler_class
      # @option options [Integer] :inserted The insertion
      #  order/position. This is used to determine sort order when two
      #  entries have the same priority.
      # @option options [Symbol] :step (:build)
      # @option options [Integer] :priority (50)
      # @option options [Set<String>, nil] :operations (nil)
      def initialize(options)
        @options = options
        @handler_class = options[:handler_class]
        @inserted = options[:inserted]
        @operations = Set.new(options[:operations]) if options[:operations]
        self.step = options[:step] || :build
        self.priority = options[:priority] || 50
        compute_weight
      end

      # @return [Handler, Class<Handler>] Returns the handler.  This may
      #  be a constructed handler object or a handler class.
      attr_reader :handler_class

      # @return [Integer] The insertion order/position.  This is used to
      #  determine sort order when two entries have the same priority.
      #  Entries inserted later (with a higher inserted value) have a
      #  lower priority.
      attr_reader :inserted

      # @return [Symbol]
      attr_reader :step

      # @return [Integer]
      attr_reader :priority

      # @return [Set<String>, nil]
      attr_reader :operations

      # @return [Integer]
      attr_reader :weight

      # @return [Integer]
      def <=>(other)
        if weight == other.weight
          other.inserted <=> inserted
        else
          weight <=> other.weight
        end
      end

      # @option options (see #initialize)
      # @return [HandlerListEntry]
      def copy(options = {})
        HandlerListEntry.new(@options.merge(options))
      end

      private

      def step=(step)
        if STEPS.key?(step)
          @step = step
        else
          msg = "invalid :step `%s', must be one of :initialize, :validate, " \
                ':build, :sign or :send'
          raise ArgumentError, msg % step.inspect
        end
      end

      def priority=(priority)
        if (0..99).include?(priority)
          @priority = priority
        else
          msg = "invalid :priority `%s', must be between 0 and 99"
          raise ArgumentError, msg % priority.inspect
        end
      end

      def compute_weight
        @weight = STEPS[@step] + @priority
      end
    end
  end
end
