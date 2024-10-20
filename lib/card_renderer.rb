require 'prawn'
require 'prawn-svg'
require 'prawn/measurement_extensions'
require 'prawn/view'
require 'yaml'

require 'text_formatter'

class CardRenderer
  include Prawn::View
  attr_reader :card_yml_file

  def initialize(card_yml_file)
    @card_yml_file = card_yml_file
  end

  def document
    @document ||= create_document
  end

  def create_document
    doc = Prawn::Document.new(page_size: [page_width, 106.mm], margin: [0,0,0,0])
    doc.font_families.update(
      "Proba Pro" => {
        normal: "/Users/heathd/Library/Fonts/ProbaPro-Regular.ttf",
        light: "/Users/heathd/Library/Fonts/ProbaPro-Light.ttf",
        semibold: "/Users/heathd/Library/Fonts/ProbaPro-SemiBold.ttf",
        bold: "/Users/heathd/Library/Fonts/ProbaPro-Bold.ttf"
      }
    )
    doc
  end

  def card
    @card ||= YAML.load_file(@card_yml_file)
  end

  def colour_for(card_type)
    {
      "Reveal" => "71c837",
      "Analyze" => "9955ff",
      "Share" => "37abc8",
      "Strategize" => "c83771",
      "Help" => "916f7c",
      "Plan" => "ff7f2a"
    }.fetch(card_type)
  end

  def page_width()= 68.mm
  def page_height()= 106.mm
  def page_top()= page_height
  def page_left()= 0.mm

  def top
    106.mm
  end

  def l_safe()= 8.mm

  def r_safe()= 60.mm

  def t_safe()= 98.mm

  def b_safe()= 8.mm

  def render
    render_background
    render_crop_area
    render_safe_area
    render_icon(width: 15.mm)
    render_title_and_purpose
    render_separator
    render_body

    start_new_page

    render_background
    render_crop_area
    render_safe_area
    render_icon(width: nil, height: 9.mm)
    render_title_and_purpose(render_purpose: false)
    render_separator(masthead_height: 12.mm)

  end

  def render_background
    fill_color 'EEEEEE'
    fill_rectangle [page_left, page_top], page_width, page_height
  end


  def crop_width()= 62.mm
  def crop_height()= 100.mm
  def crop_top()= 103.mm
  def crop_left()= 3.mm

  def render_crop_area
    fill_color 'ffffff'
    fill do
      rounded_rectangle [crop_left, crop_top], crop_width, crop_height, 3.mm
    end
  end

  def render_safe_area
    # Safe area
    fill_color 'ffffff'
    fill do
      rounded_rectangle [8.mm, 98.mm], 52.mm, 90.mm, 3.mm
    end
  end

  def icon_file
    filename = File.basename(card_yml_file, ".yml") + ".svg"
    File.dirname(__FILE__) + "/../icons/#{filename}"
  end

  def render_icon(width: 15.mm, height: nil)
    svg File.read(icon_file), at: [9.mm, 106.mm-9.mm], width: width, height: height
  end

  def title_font(size: )
    font "Proba Pro", { style: :semibold, size: size }
  end

  def body_font(size:, **kwds)
    font "Proba Pro", { style: :normal, size: size }.merge(kwds)
  end

  def masthead_height() = 25.mm
  def render_title_and_purpose(render_purpose: true)
    fill_color '000000'
    stroke_color '000000'
    bounding_box [28.mm, 106.mm-9.mm], width: 31.5.mm, height: masthead_height do
      move_to 0.mm, 20.mm
      title_font(size: 4.mm)
      text card[:title], align: :right

      if render_purpose
        body_font(size: 2.7.mm)
        text card[:purpose_statement], align: :right
      end
    end
  end

  def sep_height()= 5.mm
  def sep_bottom()= @sep_top - sep_height

  def render_separator(masthead_height: 25.mm)
    @sep_top = top - masthead_height - 9.mm
    separator_midpoint = 36.mm + l_safe
    margin = 2.mm

    fill_color colour_for(card[:card_type])
    fill_rectangle [0.mm, @sep_top], separator_midpoint, sep_height

    title_font(size: 3.5.mm)
    fill_color 'ffffff'
    text_box card[:card_type], at: [8.mm, @sep_top - 1.mm]

    fill_color 'e6e6e6'
    fill_rectangle [separator_midpoint, @sep_top], page_width - separator_midpoint, sep_height

    body_font(size: 3.5.mm)
    fill_color '000000'
    text_box card[:duration], at: [separator_midpoint, @sep_top - 1.mm], width: r_safe-separator_midpoint, align: :right

  end

  def render_body
    fill_color '000000'
    stroke_color '000000'

    body_font(size: 2.7.mm, leading: 0.2.mm)
    formatted_text_box TextFormatter.new(card[:body]).format, at: [l_safe, sep_bottom - 3.mm], height: sep_bottom - b_safe, width: 52.mm
  end

end
