class User < ActiveRecord::Base
  validates_uniqueness_of :name

  before_update :remove_name

  def restricted?
    !self.is_restricted.zero?
  end

  private

  def remove_name
    if self.name_changed?
      self.name = self.name_was
    end
  end
end
