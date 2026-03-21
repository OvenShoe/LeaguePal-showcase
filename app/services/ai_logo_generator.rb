require "openai"
require "base64"
require "stringio"

class AiLogoGenerator
  def initialize(team, description)
    @team = team
    @description = description
  end

  def generate!
    raise "No description provided" if @description.blank?

    client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))

    response = client.images.generate(
      model: "gpt-image-1",
      prompt: build_prompt,
      size: "1024x1024",
      n: 1
    )

    base64_image = response.data.first.b64_json
    raise "No image returned from OpenAI: #{response}" if base64_image.nil?

    decoded = Base64.decode64(base64_image)

    @team.logo.attach(
      io: StringIO.new(decoded),
      filename: "logo_#{@team.id}_#{Time.now.to_i}.png",
      content_type: "image/png"
    )

    @team.logo
  end

  private

  def build_prompt
    <<~PROMPT.squish
      Create a professional sports team logo for a team called #{@team.name}. #{@description}.
      The logo should be bold, modern, and suitable for a use on a sports jersey in a square format
      with a clean background with no text unless specified.
    PROMPT
  end
end
