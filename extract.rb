require 'yaml'
require 'pathname'
require 'fileutils'

root_path = Pathname.new(File.dirname(__FILE__))
path = root_path + "cards/*front.svg"
$LOAD_PATH << root_path

require 'extractor'

class Writer
  attr_reader :output_path

  def initialize(output_path)
    FileUtils.mkdir_p(output_path)
    @output_path = output_path
  end

  def write(card)
    File.open(output_path + (card.filename + ".yml"), "w") do |f|
      f.write(YAML.dump(card.card_data))
    end
  end
end

w = Writer.new(root_path + "card_yml")

class FileGlobber
  def files
    Dir["./cards/*-front.svg", "./cards/*-back.svg"]
  end

  def pairs
    grouped = files
      .group_by do |f|
        if f =~ /^(.*)-(front|back)\.svg$/
          $1
        else
          "NOMATCH"
        end
      end

    grouped.values.map do |a,b|
      if (a =~ /front/)
        [a,b]
      else
        [b,a]
      end
    end
  end
end

FileGlobber.new.pairs.each do |front,back|
  puts "file: #{front} #{back}"
  w.write(Extractor.new(front,back))
end
