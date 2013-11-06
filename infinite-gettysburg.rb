#!/usr/bin/env ruby

# You now have access to the Wordnik API. Here's your API key:
# ea70a61690a8b6d00417242c4bf2496222a195c602710ae28

# Wordnik developer resources are available here:
# http://developer.wordnik.com/

# And please join the Wordnik API user group for announcements and discussions:
# http://groups.google.com/group/wordnik-api

require 'wordnik'
require 'yaml'

Wordnik.configure do |config|
  config.api_key = 'ea70a61690a8b6d00417242c4bf2496222a195c602710ae28'
  config.logger = Logger.new('/dev/null')
end
 
text = File.read("base.txt")

ENTROPY = 0.2

def alter_text(text)
  cache = if ! File.exist?("words.yml")
            {}
          else
            YAML::load(File.read("words.yml"))
          end
  

  output = text.gsub(/\n\n/, "####").gsub(/([,\.\/])/, ' \1').split.collect { |w|
    #puts w
    tmp = if w == "," || w == "." || w == "the" || w == "--" || w == "####"
            w
          elsif rand <= ENTROPY
            clean = w
            begin
              cache[clean] ||= Wordnik.word.get_related(clean, :type => 'synonym').first
              
              cache.delete(clean) if cache[clean].is_a?(Array)
              #STDERR.puts cache[clean].inspect
              
              if cache[clean].nil? || cache[clean]["words"].empty?
                w
              else
                cache[clean]["words"].reject { |w| w =~ /see also wiki/i }.sample
              end
            rescue
              w
            end
          else
            w
          end
  }.join(" ")

  output = output.gsub(/ ([,\.\/])/, '\1').gsub(/####/, "\n\n")
  File.open('words.yml', 'w') {|f| f.write(cache.to_yaml) }
  output
end


def markdownify(text)
  text.split("\n").collect { |l| "> #{l}" }.join("\n")
end

def random_headline
  "\n\n## On, Earth-#{rand(5000)}, Lincoln gave this speech: ##\n\n"
end

output = ""
output << "\n\n\n"
output << "some copy about multiverse here"
output << "\n\n\n"

output << random_headline
output << markdownify(text)

while(output.split.size < 50000) do
  text = alter_text(text)

  output << random_headline
  output << markdownify(text)
end

puts output


