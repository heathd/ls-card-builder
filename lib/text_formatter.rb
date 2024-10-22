
class TextFormatter
  attr_reader :text
  def initialize(text)
    @text = text

    # Suppress warning due to use of bullet point
    Prawn::Fonts::AFM.hide_m17n_warning = true
  end

  def format
    paras = text
      .gsub(/^Invitation$/, "# Invitation\n")
      .gsub(/^People$/, "# People\n")
      .gsub(/^Space & Materials$/, "# Space & Materials\n")
      .gsub(/^String With$/, "# String With\n")
      .split("\n\n")
    paras.map.with_index do |para, i|
      if heading?(para)
        heading_para(para, i==0)
      elsif list?(para)
        list_para(para)
      else
        regular_para(para)
      end
    end.flatten
  end

  def list?(para)
    para =~ /^- /
  end

  def heading?(para)
    para.start_with?('#')
  end

  def heading_para(para, is_first)
    heading_para = {
      text: normalise_newlines(para.gsub(/^# */, '')),
      color: '999999',
      styles: [:bold],
      font: "Helvetica"
    }

    if is_first
      [heading_para]
    else
      [spacer_para, heading_para]
    end
  end

  def spacer_para
    {
      text: "\n",
      styles: [:normal],
      font: "Helvetica",
      size: 2.mm
    }
  end

  def regular_para(para)
    {
      text: normalise_newlines(para),
      styles: [:normal],
      font: "Helvetica"
    }
  end

  def list_para(para)
    list_items = para.split(/^- +/)

    formatted = []
    if !list_items.first.empty?
      formatted << {text: normalise_newlines(list_items.first)}
    end
    list_items[1..-1].each do |li|
      formatted << {text: "• " + normalise_newlines(li)}
    end
    formatted
  end

  def normalise_newlines(body)
    body.gsub(/\n+\Z/, "").gsub(/\n+/, " ") + "\n"
  end
end

class StringWithFormatter < TextFormatter
  def format
    paras = text.gsub(/^String With\n/, "").split("\n")
    formatted_paras = heading_para("String With", true)
    paras.each do |para|
      formatted_paras << regular_para(para)
    end

    formatted_paras.flatten
  end
end