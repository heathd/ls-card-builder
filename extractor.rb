require 'nokogiri'

class Extractor
  attr_reader :card_front_path, :card_back_path

  def initialize(card_front_path, card_back_path)
    @card_front_path = card_front_path
    @card_back_path = card_back_path
  end

  def card_front
    @card_front ||= File.open(card_front_path) {|f| Nokogiri::XML(f)}
  end

  def card_back
    @card_back ||= File.open(card_back_path) {|f| Nokogiri::XML(f)}
  end

  def title
    card_front.xpath("//svg:g[@inkscape:label='Title']//svg:flowPara")[0].text
  end

  def purpose_statement
    card_front.xpath("//svg:g[@inkscape:label='Title']//svg:flowPara")[1].text
  end

  def card_type
    tspans = card_front.xpath("//svg:g[@inkscape:label='Separator']//svg:text/svg:tspan")
    tspans.any? && tspans[0].text
  end

  def duration
    tspans = card_front.xpath("//svg:g[@inkscape:label='Separator']//svg:text/svg:tspan")
    tspans.any? && tspans[1] && tspans[1].text
  end

  def body
    card_front.xpath("//svg:g[@inkscape:label='Body']//svg:flowPara").map(&:text).map {|t| t.gsub(/\n/, " ").strip}.join("\n")
  end

  def back_body
    card_back.xpath("//svg:g[@inkscape:label='Body']//svg:flowPara").map(&:text).map {|t| t.gsub(/\n/, " ").strip}.join("\n")
  end

  def timings
    card_back
      .xpath("//svg:g[@inkscape:label='Body Right']//svg:text/svg:tspan")
      .sort_by { |tspan| tspan["y"].to_f }
      .map {|tspan| tspan.text}
  end

  def string_with
    card_back.xpath("//svg:g[@inkscape:label='String With']//svg:flowPara").map(&:text).map {|t| t.gsub(/\n/, " ").strip}.join("\n")
  end

  def filename
    f = File.basename(card_front_path, '.svg')
    f =~ /^(.*)-(front|back)/
    $1
  end

  def card_data
    {
      title: title,
      purpose_statement: purpose_statement,
      card_type: card_type,
      duration: duration,
      body: body,
      back_body: back_body,
      timings: timings,
      string_with: string_with
}
  end
end
