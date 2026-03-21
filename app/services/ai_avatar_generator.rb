require "openai"
require "anthropic"
require "base64"
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

    client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))

    person_description = describe_person
    jersey_description = describe_jersey

    response = client.images.generate(
      model:  "gpt-image-1",
      prompt: build_prompt(person_description, jersey_description),
      size:   "1024x1024",
      n:      1
    )

    base64_image = response.data.first.b64_json
    raise "No image returned from OpenAI: #{response}" if base64_image.nil?

    decoded_image = Base64.decode64(base64_image)

    TeamAvatar.enforce_limit!(@user, @team)

    @user.ai_avatars.attach(
      io:           StringIO.new(decoded_image),
      filename:     "ai_avatar_#{Time.now.to_i}.png",
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

  def describe_person
    avatar_base64 = Base64.strict_encode64(@user.avatar.download)
    avatar_media_type = @user.avatar.content_type

    client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY"))

    response = client.messages.create(
      model: "claude-haiku-4-5-20251001",
      max_tokens: 300,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: avatar_media_type,
                data: avatar_base64
              }
            },
            {
              type: "text",
              text: "Describe this person's physical appearance in detail: face shape, skin tone, hair colour and style, eye colour, age range, and any distinctive features. Be specific and concise. This will be used to generate an AI avatar."
            }
          ]
        }
      ]
    )

    response.content.first.text
  end

  def describe_jersey
    jersey_base64 = Base64.strict_encode64(@team.jersey.download)
    jersey_media_type = @team.jersey.content_type

    client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY"))

    response = client.messages.create(
      model: "claude-haiku-4-5-20251001",
      max_tokens: 300,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: jersey_media_type,
                data: jersey_base64
              }
            },
            {
              type: "text",
              text: "Describe this sports team jersey's colours, design, and any logos or badges in 2-3 sentences. Be specific and concise."
            }
          ]
        }
      ]
    )

    response.content.first.text
  end

  def build_prompt(person_description, jersey_description)
    "Create a photo-realistic sports portrait avatar of a person with the following appearance: #{person_description}. " \
    "They are wearing a #{@team.name} team jersey that looks like this: #{jersey_description}. " \
    "Frame the image as a centred headshot: face occupies the top 40% of the frame, " \
    "shoulders visible at the bottom, neutral background. Present only the famy and upper torso with no limbs if profile picture has limbs." \
    "Square 1:1 aspect ratio. No text. No distortion of the person's face."
  end
end
