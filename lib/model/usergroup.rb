class Usergroup < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships

  validates_uniqueness_of :name, :message => 'name has already been taken'
end
