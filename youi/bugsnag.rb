#!/usr/bin/env ruby

require 'shellwords'
require 'optparse'
require 'ostruct'

class GenerateOptions
  def self.parse(args)
      options = OpenStruct.new
      options.platform = nil
      options.configuration = "Debug"
      options.build_directory = nil
      options.project_directory = nil
      options.apiKey = "ec866230dd7116c94845586bafc31326"

      platformList = ["Android", "Bluesky2", "Bluesky4", "Ios", "Linux", "Osx", "Ps4", "Tizen-Nacl", "Tvos", "Uwp", "Vestel130", "Vestel211", "Vestel230", "Vs2017", "Webos3", "Webos4"]
      configurationList = ["Debug", "Release"]

      options_parser = OptionParser.new do |opts|
          opts.banner = "Usage: bugsnag.rb [options]"

          opts.separator ""
          opts.separator "Arguments:"

          opts.on("-p", "--platform PLATFORM", String,
              "(REQUIRED) The name of the platform to generate the project for.",
              "  Supported platforms: #{platformList}") do |platform|
              unless platformList.any? { |s| s.casecmp(platform)==0 }
                  puts "ERROR: \"#{platform}\" is an invalid platform."
                  puts opts
                  exit 1
              end

              options.platform = platform
          end

          opts.on("-k", "--key API KEY", String,
            "The Bugsnag API key is used to identify which project to upload the dSYMs to."
          ) do |key|
            options.apiKey = key
          end

          opts.on("-c", "--config CONFIGURATION", String,
              "The configuration type #{configurationList} to send to the generator.",
              "  (This is only required for generators that do not support multiple configurations.)") do |config|
              if configurationList.any? { |s| s.casecmp(config)==0 }
                  options.configuration = config
              else
                  puts "ERROR: \"#{config}\" is an invalid configuration type."
                  puts opts
                  exit 1
              end
          end
      end

      if args.count == 0
          puts options_parser
          exit 1
      end

      begin
          options_parser.parse!(args)
          mandatory = [:platform]
          missing = mandatory.select { |param| options[param].nil? }
          raise OptionParser::MissingArgument, missing.join(', ') unless missing.empty?

          unless options.build_directory
              options.project_directory = File.expand_path(__dir__)
              options.build_directory = File.expand_path(File.join(__dir__, "build", "#{options.platform.downcase}"))
          end

          return options
      rescue OptionParser::ParseError => e
          puts e
          puts ""
          puts options_parser
          exit 1
      end
  end
end

options = GenerateOptions.parse(ARGV)

fork do
  Process.setsid
  STDIN.reopen("/dev/null")
  STDOUT.reopen("/dev/null", "a")
  STDERR.reopen("/dev/null", "a")

  Dir.glob("#{options.build_directory}/#{options.configuration}-*/**/Contents/Resources/DWARF/*") do |dsym|
    system("curl -s --http1.1 -F apiKey=#{options.apiKey} -F dsym=@#{Shellwords.escape(dsym)} -F projectRoot=#{Shellwords.escape(options.project_directory)} https://upload.bugsnag.com/")
  end
end
