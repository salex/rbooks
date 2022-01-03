module ComponentsHelper
  def greenBox
    "box-border box-content m-3 p-4 bg-green-300 border-green-100 border-2 text-black"
  end

  def blueBox
    "box-border box-content m-3 p-4 bg-blue-400 border-blue-200 border-2 text-black"
  end

  def btn
    "py-1 px-2 text-black hover:text-white rounded font-lg font-bold "
  end

  def btnInfo
    btn + "bg-blue-400 text-blue-link hover:text-blue-200"
  end

  def btnWarn
    btn + "bg-orange hover:text-yellow-200"
  end

  def btnGreen
    btn + "bg-green-500 hover:text-green-200"
  end

  def btnDanger
    btn + "bg-red-500 hover:text-red-200"
  end

  def btnSuccess
    btn + "bg-success hover:bg-green-700"
  end

  def btnSecondary
    btn + "bg-secondary"
  end

  def flashAlert(type)
    case type
    when 'danger'
      return "bg-red-200 text-red-600"
    when 'info'
      return "bg-blue-200 text-blue-600"
    when 'success'
      return "bg-green-200 text-green-600"
    when 'warning'
      return "bg-yellow-400 text-yellow-800"
    else
      return "bg-gray-200 text-gray-600"
    end
  end

  def destroyConfirmTag(model,confirm_msg:"",klass:"",prompt:"")
    klass= "#{btnDanger} inline-block" if klass.blank?
    confirm_msg = "Are You Sure?" if confirm_msg.blank?
    prompt = "Delete #{model.class.name}" if prompt.blank?
    node = content_tag(:div, class: klass,
      data:{
        controller:"destroyConfirm", 
        action:"click->destroyConfirm#confirm",
        destroyConfirm_cmsg_value:confirm_msg
      }){
      concat(tag.span(prompt))
      concat(button_to( '',model, method: :delete,class:"hidden",data:{destroyConfirm_target:"submit"}))
    }
    node 
  end

end
