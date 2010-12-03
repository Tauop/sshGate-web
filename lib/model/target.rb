class Target < ActiveRecord::Base
  validates_presence_of   :name, :on => :create, :message => 'name is required'
  validates_uniqueness_of :name, :message => 'name has already been taken'

  attr_accessor :private_key, :public_key

  before_save :save_private_key, :generate_public_key
  after_find  :load_keys

  def ssh_x11_enabled?
    !self.ssh_enable_x11.zero?
  end

  private

  def save_private_key
    unless self.private_key.blank?
      key_file = File.join(settings.targets_keys_dir, self.name)
      File.open(key_file, 'w+') do |f|
        f.print self.private_key
        self.private_key_file = key_file
        f.chmod(0600)
      end
    end
  end

  def generate_public_key
    unless self.private_key_file.blank?
      public_key = %x( ssh-keygen -y -f #{self.private_key_file} )
      key_file = File.join(settings.targets_keys_dir, "#{self.name}.pub")
      File.open(key_file, 'w+') do |f|
        f.print public_key
        self.public_key_file = key_file
      end
    end
  end

  def load_keys
    %w(private public).each do |key|
      instance_eval <<-LoadKey
        if self.#{key}_key_file?
          if File.exists?(self.#{key}_key_file)
            self.#{key}_key = File.read(self.#{key}_key_file)
          end
        end
      LoadKey
    end
  end
end
