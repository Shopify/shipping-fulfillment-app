class Morechangestovariants < ActiveRecord::Migration
  def up
    remove_column :variants, :activated
  end
end
