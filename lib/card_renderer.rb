require 'prawn'
require 'prawn-svg'
require 'prawn/table'
require 'prawn/measurement_extensions'
require 'prawn/view'
require 'yaml'

require 'text_formatter'

class CardRenderer
  include Prawn::View
  attr_reader :card_yml_file, :errors

  def initialize(card_yml_file, document: nil, errors: [])
    @card_yml_file = card_yml_file
    @document = document
    @errors = errors
  end

  def document
    @document ||= self.default_document
  end

  def self.default_document
    doc = Prawn::Document.new(page_size: [PAGE_WIDTH, 106.mm], margin: [0,0,0,0])
    # doc.font_families.update(
    #   "Proba Pro" => {
    #     normal: "/Users/heathd/Library/Fonts/ProbaPro-Regular.ttf",
    #     light: "/Users/heathd/Library/Fonts/ProbaPro-Light.ttf",
    #     semibold: "/Users/heathd/Library/Fonts/ProbaPro-SemiBold.ttf",
    #     bold: "/Users/heathd/Library/Fonts/ProbaPro-Bold.ttf"
    #   }
    # )
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

  PAGE_WIDTH = 68.mm
  def page_width()= PAGE_WIDTH
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
    render_back_body
  end

  def render_background
    fill_color 'ffffff'
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
    font "Helvetica", { style: :bold, size: size }
  end

  def heading_font(size: )
    font "Helvetica", { style: :bold, size: size}
  end

  def body_font(size:, **kwds)
    font "Helvetica", { style: :normal, size: size }.merge(kwds)
  end

  def masthead_height() = 25.mm
  def render_title_and_purpose(render_purpose: true)
    fill_color '000000'
    stroke_color '000000'
    bounding_box [26.mm, 106.mm-9.mm], width: 33.5.mm, height: masthead_height do
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
  def separator_midpoint() = 36.mm + l_safe

  def render_separator(masthead_height: 25.mm)
    @sep_top = top - masthead_height - 9.mm
    margin = 2.mm

    if split_card_type?
      render_split_card_type
    else
      render_card_type
    end

    fill_color 'e6e6e6'
    fill_rectangle [separator_midpoint, @sep_top], page_width - separator_midpoint, sep_height

    body_font(size: 3.5.mm)
    fill_color '000000'
    text_box card[:duration], at: [separator_midpoint, @sep_top - 1.mm], width: r_safe-separator_midpoint, align: :right

  end

  def split_card_type?
    card[:card_type] =~ %r{/}
  end

  def render_split_card_type
    first, second = card[:card_type].split("/").map(&:strip)

    slant_midpoint = l_safe + 15.mm
    slant_offset = 1.5.mm
    fill_color colour_for(first)
    fill_polygon [0.mm, @sep_top],
                 [slant_midpoint + slant_offset, @sep_top],
                 [slant_midpoint - slant_offset, @sep_top - sep_height],
                 [0.mm, @sep_top - sep_height]
    title_font(size: 3.5.mm)
    fill_color 'ffffff'
    text_box first, at: [8.mm, @sep_top - 1.mm]

    fill_color colour_for(second)
    fill_polygon [slant_midpoint + slant_offset, @sep_top],
                   [separator_midpoint, @sep_top],
                   [separator_midpoint, @sep_top - sep_height],
                   [slant_midpoint - slant_offset, @sep_top - sep_height]

    title_font(size: 3.5.mm)
    fill_color 'ffffff'

    if second == "Strategize"
      text_box second, at: [separator_midpoint/2 + 3.5.mm, @sep_top - 1.mm], width: separator_midpoint/2 - 3.5.mm - 1.5.mm
    else
      text_box second, at: [separator_midpoint/2 + 5.mm, @sep_top - 1.mm], width: separator_midpoint/2 - 5.mm - 1.mm
    end
  end

  def render_card_type
    fill_color colour_for(card[:card_type])
    fill_rectangle [0.mm, @sep_top], separator_midpoint, sep_height

    title_font(size: 3.5.mm)
    fill_color 'ffffff'
    text_box card[:card_type], at: [8.mm, @sep_top - 1.mm]
  end

  def render_body
    fill_color '000000'
    stroke_color '000000'

    body_font(size: 2.6.mm, leading: 0.2.mm)
    padding_below_separator = 3.mm
    left_over = formatted_text_box TextFormatter.new(card[:body]).format,
                                   at: [l_safe, sep_bottom - padding_below_separator],
                                   height: sep_bottom - b_safe - padding_below_separator,
                                   width: 52.mm
    if left_over.any?
      collect_error(ExcessTextError.new(card, :front, left_over))
    end
  end

  class ExcessTextError
    attr_reader :card, :front_or_back, :excess_text_hashes
    def initialize(card, front_or_back, excess_text_hashes)
      @card = card
      @front_or_back = front_or_back
      @excess_text_hashes = excess_text_hashes
    end

    def excess_text
      excess_text_hashes.map {|l| l[:text]}.join(" ").gsub("\n", " ")
    end

    def card_title
      card[:title]
    end

    def to_s
      "#{card_title} had some text which didn't fit on the #{front_or_back} side: '#{excess_text}'"
    end
  end

  class TableOverflowedError
    attr_reader :card, :front_or_back
    def initialize(card, front_or_back)
      @card = card
      @front_or_back = front_or_back
    end

    def card_title
      card[:title]
    end

    def to_s
      "#{card_title}: the table on the #{front_or_back} side overflowed"
    end
  end

  def collect_error(error)
    @errors ||= []
    @errors << error
  end

  def render_back_body
    paras = card[:back_body].gsub(/^.*Steps\n/, "").split("\n\n")
    timings = card[:timings]
    data = paras.zip(timings)

    padding = 2.5.mm

    bounding_box [l_safe, sep_bottom-padding], width: r_safe-l_safe, height: sep_bottom - b_safe do
      fill_color '999999'
      heading_font(size: 2.5.mm)
      text "Steps"

      fill_color '000000'
      body_font(size: 2.5.mm)

      current_page_number = document.page_number

      table = table(data,
            cell_style: { borders: [], padding: [0, 2.mm, 3.mm, 0]},
            column_widths: { 1 => 10.mm}) do
        columns(1).align = :right
      end

      if current_page_number < document.page_number
        collect_error(TableOverflowedError.new(card, :back))
      end

      if !card[:string_with].empty?
        left_over = formatted_text_box StringWithFormatter.new(card[:string_with]).format, at: [0, cursor], width: 52.mm
        if left_over.any?
          collect_error(ExcessTextError.new(card, :back, left_over))
        end
      end
    end
  end

end
