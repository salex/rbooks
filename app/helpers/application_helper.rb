module ApplicationHelper
  def show_table_row(label,data)
    content_tag :tr do
      concat(show_label(label) + show_data(data))
    end
  end

  def show_label(label)
    content_tag :th, label
  end

  def icon(klass, text = nil)
    icon_tag = tag.i(class: klass)
    text_tag = tag.span text
    text ? tag.span(icon_tag + text_tag) : icon_tag
  end


  def show_data(data)
    content_tag :td, data
  end

  def inspect_session
    inspect = {}
    session.keys.each do |k|
      inspect[k] = session[k]
    end
    inspect
  end
  alias session_inspect inspect_session

  def dmoney(decimal,unit="")
   return 0 if decimal.blank? || decimal.zero?
    number_to_currency(decimal,unit:unit)
  end


end
