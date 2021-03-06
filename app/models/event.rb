require 'json'
require 'ext/hash'

class Event < ApplicationRecord

  self.inheritance_column = :event_type

  before_validation :default_values

  validates :cmd_type, presence: true
  validates :cmd_uuid, presence: true

  jsonb_accessor :jfields, :etherscan_url => :string

  # generate jsonb fields for a class
  def self.jsonb_fields_for(field, klas, opts = {})
    fields = klas.attribute_names.reduce({}) do |acc, name|
      sname = name.to_s
      acc[sname] = klas.columns_hash[sname]&.type
      acc
    end

    new_fields = fields
      .without_blanks
      .merge(opts.fetch(:extras, {}))
      .without(*(opts.fetch(:exclude, [])))
      .delete_if {|k, v| %i(jsonb hstore tsrange).include?(v)}
      .delete_if {|k, v| %w(created_at updated_at).include?(k)}

    new_fields.each do |key, val|
      jsonb_accessor field, {key => val}
    end
  end

  class << self
    def for_user(user)
      # user_id = user.to_i
      # where("? = any(user_uuids)", user_id)
      where(false)
    end
  end

  def ev_cast
    if valid?
      if new_object&.save
        self.projected_at = BugmTime.now
        self.send(:save!)
      end
      new_object
    else
      nil
    end
  end

  def cast_object
    raise "ERROR: Call in SubClass"
  end

  def new_object
    @cast_element ||= cast_object
  end

  private

  def save(*)
    super
  end

  def default_values
    prev = Event.last
    self.payload     ||= {}
    self.event_uuid  ||= SecureRandom.uuid
    self.local_hash    = Digest::MD5.hexdigest([self.uuid, payload].to_json)
    self.chain_hash    = Digest::MD5.hexdigest([prev&.chain_hash, self.local_hash].to_json)
  end
end

# == Schema Information
#
# Table name: events
#
#  id           :integer          not null, primary key
#  event_type   :string
#  event_uuid   :string
#  cmd_type     :string
#  cmd_uuid     :string
#  local_hash   :string
#  chain_hash   :string
#  payload      :jsonb            not null
#  jfields      :jsonb            not null
#  user_uuids   :string           default([]), is an Array
#  projected_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
