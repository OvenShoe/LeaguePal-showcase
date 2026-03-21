require "openai"
require "base64"
require "tempfile"
require "stringio"

class AiAvatarGenerator
  MAX_AVATARS = 8

  def initialize(user, team)
    @user = user
    @team = team
  end

  def generate!
    raise "User has no avatar uploaded" unless @user.avatar.attached?
    raise "Team has no jersey uploaded" unless @team.jersey.attached?

    # fetch API key as string, fail early if missing
    client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))

    avatar_tempfile = Tempfile.new(["avatar", ".png"])

    begin
      avatar_tempfile.binmode
      avatar_tempfile.write(@user.avatar.download)
      avatar_tempfile.rewind

      response = client.images.edit(
        model:            "gpt-image-1",
        image:            avatar_tempfile,
        prompt:           build_prompt,
        size:             "1024x1024",
      )
    ensure
      avatar_tempfile.close
      avatar_tempfile.unlink
    end

    base64_image = response.dig("data", 0, "b64_json")
    raise "No image returned from OpenAI: #{response}" if base64_image.nil?

    decoded_image = Base64.decode64(base64_image)

    TeamAvatar.enforce_limit!(@user, @team)

    @user.ai_avatars.attach(
      io: StringIO.new(decoded_image),
      filename: "ai_avatar_#{Time.now.to_i}.png", # unique filename
      content_type: "image/png"
    )

    blob = @user.ai_avatars.last.blob

    TeamAvatar.create!(
      user: @user,
      team: @team,
      blob: blob
    )

    blob
  end

  private

  def build_prompt
    <<~PROMPT.squish
      Create a photo-realistic sports portrait avatar of this exact person wearing the #{@team.name} team jersey shown in the reference image.
      The jersey design, colours, badge, and logos must match exactly.
      Frame the image as a centred headshot: face occupies the top 40% of the frame,
      shoulders visible at the bottom, neutral background.
      Square 1:1 aspect ratio. No text. No distortion of the person's face.
    PROMPT
  end
end
