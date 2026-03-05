class ChangeRoleToIntegerInTeamMembers < ActiveRecord::Migration[8.1]
  def up
    # Change existing string values to integer equivalents
    execute <<-SQL
      UPDATE team_members
      SET role = CASE
        WHEN LOWER(role) = 'captain' THEN '1'
        ELSE '0'
      END
    SQL

    # Change column type to integer with default
    change_column :team_members, :role, :integer, default: 0, null: false, using: 'role::integer'
  end

  def down
    change_column :team_members, :role, :string
  end
end
