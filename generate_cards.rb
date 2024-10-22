$LOAD_PATH << File.dirname(__FILE__) + "/lib/"
require 'card_renderer'
require 'pathname'


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
  end
end

order = %w{
  1-2-4-all.yml
  impromptu-networking.yml
  nine-whys.yml
  wicked-questions.yml
  appreciative-interviews.yml
  triz.yml
  15-percent-solutions.yml
  troika-consulting.yml
  what-3.yml
  discovery-and-action-dialog.yml
  shift-and-share.yml
  25-10-crowd-sourcing.yml
  wise-crowds.yml
  min-specs.yml
  improv-prototyping.yml
  helping-heuristics.yml
  conversation-cafe.yml
  user-experience-fishbowl.yml
  heard-seen-respected.yml
  drawing-together.yml
  design-storyboards.yml
  celebrity-interview.yml
  social-network-webbing.yml
  what-i-need-from-you.yml
  open-space-technology.yml
  generative-relationships.yml
  agreement-certainty-matrix.yml
  simple-ethnography.yml
  integrated-autonomy.yml
  critical-uncertainties.yml
  ecocycle-planning.yml
  panarchy.yml
  purpose-to-practice.yml
}

path = File.dirname(__FILE__) + "/card_yml/"

document = CardRenderer.default_document
errors = []
order.each.with_index do |card_yml, i|
  document.start_new_page if i>0
  card = CardRenderer.new(path + card_yml, document: document, errors: errors)
  card.render
end

if errors.any?
  puts "There were #{errors.count} error(s):"
  errors.each do |error|
    puts error.to_s
  end
end

document.render_file("pdfs/cards.pdf")
puts "rendered #{order.count} cards to pdfs/cards.pdf"