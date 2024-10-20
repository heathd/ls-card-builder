$LOAD_PATH << File.dirname(__FILE__) + "/lib/"
require 'card_renderer'
require 'pathname'

all_cards = Dir[File.dirname(__FILE__) + "/card_yml/*.yml"]

class Mapper
  attr_reader :card_yml
  def initialize(card_yml)
    @card_yml = card_yml
  end

  def base_filename() = File.basename(card_yml, ".yml")
  def output_dir
    Pathname.new(File.dirname(__FILE__)) + "pdfs"
  end
  def output_filename
    output_dir + (base_filename + ".pdf")
  end

  def map!
    FileUtils.mkdir_p(output_dir)

    puts "Writing #{output_filename}"
    card = CardRenderer.new(card_yml)
    card.render
    card.save_as(output_filename)
  end
end

all_cards.each do |card_yml|
  next if card_yml =~ /main.yml/
  Mapper.new(card_yml).map!
end