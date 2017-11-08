class Repo::GitHub < Repo

  validates :name, uniqueness: true, presence: true
  validates :name, format: { with:    /\A[\_\-\.a-zA-Z0-9]+\/[\.\_\-a-zA-Z0-9]+\z/,
                             message: "needs GitHub repo '<user>/<repo>'" }

  hstore_accessor :xfields  , :languages  => :string    # add field to hstore

  validate :repo_presence

  after_create :set_languages

  def html_url
    "https://github.com/#{self.name}"
  end

  private

  def set_languages
    languages = Octokit.languages(self.name)
    update_attribute :languages, languages.to_hash.keys.map(&:to_s).join(", ")
  end

  def repo_presence
    repo = Octokit.repo(self.name)
    return if repo.present?
    errors.add :name, "GitHub repo does not exist"
  end
end

# == Schema Information
#
# Table name: repos
#
#  id         :integer          not null, primary key
#  type       :string
#  name       :string
#  xfields    :hstore           not null
#  jfields    :jsonb            not null
#  synced_at  :datetime
#  exref      :string
#  uuref      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
