module ApplicationHelper

  def label_style_helper(status)
    case status
    when "success"
      "label-success"
    when "pending"
    else
      "label-error"
    end
  end
end
