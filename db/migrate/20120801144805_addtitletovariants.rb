class Addtitletovariants < ActiveRecord::Migration
  def change
    add_column :variants, :title, :string
  end
end