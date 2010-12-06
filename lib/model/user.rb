class User < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :usergroups, :through => :memberships

  validates_uniqueness_of :name, :message => 'name has already been taken'

  attr_accessor :public_key
  before_update :remove_name

  before_save :save_public_key
  after_find  :load_public_key

  def admin?
    !self.is_admin.zero?
  end

  def restricted?
    !self.is_restricted.zero?
  end

  private

  def save_public_key
    unless self.public_key.blank?
      key_file = File.join(settings.users_keys_dir, "#{self.name}.pub")
      File.open(key_file, 'w+') do |f|
        f.print self.public_key
        self.public_key_file = key_file
      end
    end
  end

  def load_public_key
    if self.public_key_file?
      if File.exists?(self.public_key_file)
        self.public_key = File.read(self.public_key_file)
      end
    end
  end

  def remove_name
    if self.name_changed?
      self.name = self.name_was
    end
  end
end
