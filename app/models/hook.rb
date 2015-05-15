class Hook < ActiveRecord::Base
  self.primary_key = :id

  validates_presence_of :slack_hook

  def self.new_endpoint
    new(id: Digest::MD5.new.update(Random.new_seed.to_s))
  end
end
