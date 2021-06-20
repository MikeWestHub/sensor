# Validates inputs provided from the command line

module Sensor
  class ValidationError < StandardError
  end

  class CommandLineValidator
    attr_reader :options

    def initialize(input:)
      @options = input.dup
      @filename = @options.delete(:filename)
    end

    def validate
      check_file
      check_write
      check_update
      check_delete
      check_execute
      check_content
    end

    private

    def check_file
      return if options[:write] && only_true_flag?
      raise_error(message: "File #{@filename} not found. Please provide the full path to the file") unless File.exist?(@filename)
    end

    def check_write
      if options[:write] == true
        raise_error(message: "--write flag must be passed with --content") unless content_included?
        raise_error(message: "--content is the only supported flag to pass with --write") unless only_true_flag?
      end
    end

    def check_update
      if options[:update] == true
        raise_error(message: "--update flag must be passed with --content") unless content_included?
        raise_error(message: "--content is the only supported flag to pass with --update") unless only_true_flag?
      end 
    end

    def check_delete
      if options[:delete] == true
        message = "--delete cannot be passed with other flags"

        raise_error(message: message) if content_included?
        raise_error(message: message) unless only_true_flag?
      end
    end

    def check_execute
      if options[:execute] == true
        message = "--execute cannot be passed with other flags"

        raise_error(message: message) if content_included?
        raise_error(message: message) unless only_true_flag?
      end
    end

    def check_content
      return unless content_included?

      write_or_update = options.keys.include?(:write) || options.keys.include?(:update)
      raise_error(message: "--write or --update flags must be provided with --content") unless write_or_update
    end

    def content_included?
      !options[:content].nil?
    end

    def only_true_flag?
      opts = options.dup
      opts.delete(:content)
      opts.delete(:forward)

      return false if opts.values.size > 1
      true
    end

    def raise_error(message:)
      raise ValidationError.new(message: message)
    end
  end
end
