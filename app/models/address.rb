# == Schema Information
#
# Table name: addresses
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  province   :string
#  district   :string
#  ward       :string
#  street     :string
#  geocoding  :text             default([]), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Address < ActiveRecord::Base
  belongs_to  :user

  def full_address
    "#{street}, #{ward}, #{district}, #{province}"
  end
end
