class User < ApplicationRecord
  belongs_to :team, optional: true
  has_many :trophies

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Use avatar in user edit and create forms
  has_one_attached :avatar
  has_many_attached :ai_avatars

  has_many :competition_admins, dependent: :destroy
  has_many :competitions, through: :competition_admins

  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members

  has_many :stats, dependent: :destroy
  has_many :trophies, through: :team_members

  def is_admin?
    competition_admins.exists?
  end

  def is_captain_of?(team)
    team_members.exists?(team: team, role: :captain)
  end

  def list_name
    "#{first_name} #{last_name}: #{email}".strip
  end

  def name
     "#{first_name} #{last_name}"
  end
end
