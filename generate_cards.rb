require 'prawn'
require 'prawn-svg'
require 'prawn/measurement_extensions'
require 'prawn/view'

require 'yaml'

class CardRenderer
  include Prawn::View

  def document
    @document ||= Prawn::Document.new(page_size: [68.mm, 106.mm], margin: [0,0,0,0])
  end

  def card
    @card ||= YAML.load_file(File.dirname(__FILE__) + "/card_yml/1-2-4-all.yml")
  end

  def colour_for(card_type)
    {
      "Reveal" => "71c837"
    }.fetch(card_type)
  end

  def top
    106.mm
  end

  def render
    render_background
    render_crop_area
    render_safe_area
    render_icon
    render_title_and_purpose
    render_separator
  end

  def render_background
    fill_color 'FF8844'
    fill_rectangle [0.mm,106.mm], 68.mm, 106.mm
  end

  def render_crop_area
    fill_color 'CCFF88'
    fill do
      rounded_rectangle [3.mm, 103.mm], 62.mm, 100.mm, 3.mm
    end
  end

  def render_safe_area
    # Safe area
    fill_color 'FFFFFF'
    fill do
      rounded_rectangle [8.mm, 98.mm], 52.mm, 90.mm, 3.mm
    end
  end

  def render_icon
    svg File.read(File.dirname(__FILE__) + "/icons/1-2-4-all.svg"), at: [9.mm, 106.mm-9.mm], width: 15.mm
  end

  def render_title_and_purpose
    fill_color '000000'
    stroke_color '000000'
    bounding_box [28.mm, 106.mm-9.mm], width: 31.5.mm, height: 23.mm do
      move_to 0.mm, 20.mm
      font "Helvetica", style: :bold, size: 4.mm
      text card[:title],align: :right

      font "Helvetica", style: :normal, size: 3.mm

      text card[:purpose_statement], align: :right
    end
  end

  def render_separator
    lsep_w = 36.mm
    sep_top = top - 32.mm
    margin = 2.mm

    fill_color colour_for(card[:card_type])
    fill_rectangle [8.mm, sep_top], lsep_w, 5.mm

    font "Helvetica", style: :bold, size: 4.mm
    fill_color 'ffffff'
    text_box card[:card_type], at: [8.mm+margin, sep_top - 2.pt]

    fill_color 'e6e6e6'
    fill_rectangle [8.mm+lsep_w, sep_top], 52.mm-lsep_w, 5.mm

    font "Helvetica", style: :normal, size: 4.mm
    fill_color '000000'
    text_box card[:duration], at: [8.mm+lsep_w, sep_top - 2.pt], width: 52.mm-lsep_w-margin, align: :right

  end
end

card = CardRenderer.new
card.render

card.save_as("hello.pdf")
