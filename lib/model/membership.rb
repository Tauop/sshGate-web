class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :usergroup

  validates_associated :user
  validates_associated :usergroup
  validates_uniqueness_of :user_id,
    :scope   => :usergroup_id,
    :message => 'this membership already exists'

  def initialize(data={})
    set_real_assoc data
    super
  end

  def update_attributes(data={})
    set_real_assoc data
    super
  end

  def must_be_uniq
    errors.add_to_base("COUCOU") unless self.grouping.unique?
  end

  private

  def set_real_assoc(data={})
    data[:user]      = User.find_by_name(data[:user])           if data[:user]      && data[:user].is_a?(String)
    data[:usergroup] = Usergroup.find_by_name(data[:usergroup]) if data[:usergroup] && data[:usergroup].is_a?(String)
  end
end
