class OrderUpdateJob
@queue = :default

  def self.perform(line_items)
    line_items.each do |item|
      line_item = LineItem.where('line_item_id = ?', item['id']).first
      line_item.update_attribute('fulfillment_status', item['fulfillment_status'])
    end
  end
end