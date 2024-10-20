
class TextFormatter
  attr_reader :text
  def initialize(text)
    @text = text
  end

  def format
    paras = text.split("\n\n")
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
    para.start_with?("-")
  end

  def heading?(para)
    para.start_with?('#')
  end

  def heading_para(para, is_first)
    heading_para = {
      text: normalise_newlines(para.gsub(/^# */, '')),
      color: '999999',
      styles: [:bold],
      font: "Proba Pro"
    }

    if is_first
      [heading_para]
    else
      [spacer_para, heading_para]
    end
  end

  def spacer_para
    {text: "\n",
    styles: [:normal],
      font: "Proba Pro"}
  end

  def regular_para(para)
    {
      text: normalise_newlines(para),
      styles: [:normal],
      font: "Proba Pro"
    }
  end

  def list_para(para)
    list_items = para.split(/^- +/)
    list_items.reject(&:empty?).map do |li|
      {text: "• #{normalise_newlines(li)}"}
    end
  end

  def normalise_newlines(body)
    body.gsub(/\n+\Z/, "").gsub(/\n+/, " ") + "\n"
  end
end