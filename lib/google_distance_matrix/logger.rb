# frozen_string_literal: true

module GoogleDistanceMatrix
  # Logger class for Google Distance Matrix
  class Logger
    PREFIXES = %w[google_distance_matrix].freeze
    LEVELS = %w[fatal error warn info debug].freeze

    attr_reader :backend

    def initialize(backend = nil)
      @backend = backend
    end

    LEVELS.each do |level|
      define_method level do |*args|
        options = args.extract_options!.with_indifferent_access

        msg = args.first
        tags = PREFIXES.dup.concat Array.wrap(options[:tag])

        backend&.public_send level, tag_msg(msg, tags)
      end
    end

    def level
      backend&.level
    end

    private

    def tag_msg(msg, tags)
      msg_buffer = tags.map { |tag| "[#{tag}]" }
      msg_buffer << msg
      msg_buffer.join ' '
    end
  end
end
