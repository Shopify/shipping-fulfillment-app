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

  def other_filters(management)
    filters = {
      'Shipwire' => '/variants/filter/shipwire',
      'Shopify' => '/variants/filter/shopify',
      'Other' => '/variants/filter/other',
      'None' => '/variants/filter/none'
    }
    filters.delete(management)
    filters
  end

  def geolocation?(address)
    address[:latitude] && address[:longitude] if address
  end
end