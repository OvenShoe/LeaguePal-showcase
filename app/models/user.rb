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

  def has_games?
    games_relation.exists?
  end

  def upcoming_games
    games_relation
      .where("start_time >= ?", Time.current)
      .order(:start_time)
  end

  def past_games
    games_relation
      .where("start_time < ?", Time.current)
      .order(start_time: :desc)
  end

  def next_game
    upcoming_games.first
  end

  private

  def games_relation
    team_ids = teams.select(:id)
    return Game.none if team_ids.blank?

    Game.where(team_1_id: team_ids)
        .or(Game.where(team_2_id: team_ids))
  end
end
