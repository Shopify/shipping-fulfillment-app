module VariantsHelper
  def inventory_label(quantity)
    if (0..2).to_a.include?(quantity)
      'label label-important'
    elsif (3..10).to_a.include?(quantity)
      'label label'
    else
      'label label-success'
    end
  end
end
