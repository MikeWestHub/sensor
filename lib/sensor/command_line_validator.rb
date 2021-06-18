# Validates input provided from the command line

module Sensor
  class ValidationError < StandardError
  end

  class CommandLineValidator
    attr_reader :input

    def initialize(input:)
      @input = input
    end

    def validate
      check_write
      check_update
      check_delete
      check_execute
    end

    private

    def check_write
      if input[:write] == true
        raise_error(message: "--write flag must be passed with --content") unless content_included?
        raise_error(message: "--content is the only supported flag to pass with --write") unless only_true_flag?
      end
    end

    def check_update
      if input[:update] == true
        raise_error(message: "--update flag must be passed with --content") unless content_included?
        raise_error(message: "--content is the only supported flag to pass with --update") unless only_true_flag?
      end 
    end

    def check_delete
      if input[:delete] == true
        message = "--delete cannot be passed with other flags"

        raise_error(message: message) if content_included?
        raise_error(message: message) unless only_true_flag?
      end
    end

    def check_execute
      if input[:execute] == true
        message = "--execute cannot be passed with other flags"

        raise_error(message: message) if content_included?
        raise_error(message: message) unless only_true_flag?
      end
    end

    def content_included?
      !input[:content].nil?
    end

    def only_true_flag?
      opts = input
      opts.delete(:file)
      opts.delete(:content)

      return false if opts.values.size > 1
      true
    end

    def raise_error(message:)
      raise ValidationError.new(message: message)
    end
  end
end
