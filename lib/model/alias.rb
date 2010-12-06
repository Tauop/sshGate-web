class Alias < ActiveRecord::Base
  belongs_to :target

  validates_presence_of   :name, :message => 'name is required'
  validates_uniqueness_of :name, :message => 'name has already been taken'
  validates_presence_of   :target_id, :message => 'target is required'

  scope :target,
    lambda { |target_name|
      joins(:target).where('targets.name = ?', target_name)
    }

  attr_accessor :target_name
  before_save :save_target

  private

  def save_target
    self.target = Target.find_by_name(self.target_name) unless self.target_name.blank?
  rescue
    self.target_id = nil
  end
end
