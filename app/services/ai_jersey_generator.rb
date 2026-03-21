require "openai"
require "anthropic"
require "base64"
require "stringio"

class AiJerseyGenerator
  def initialize(team, description = nil)
    @team = team
    @description = description
  end

  def generate!
    raise "Team has no logo to use as reference" unless @team.logo.attached?

    client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))

    logo_description = describe_logo

    response = client.images.generate(
      model:  "gpt-image-1",
      prompt: build_prompt(logo_description),
      size:   "1024x1024",
      n:      1
    )

    base64_image = response.data.first.b64_json
    raise "No image returned from OpenAI: #{response}" if base64_image.nil?

    decoded = Base64.decode64(base64_image)

    @team.jersey.attach(
      io:           StringIO.new(decoded),
      filename:     "jersey_#{@team.id}_#{Time.now.to_i}.png",
      content_type: "image/png"
    )

    @team.jersey
  end

  private

  def describe_logo
    logo_base64 = Base64.strict_encode64(@team.logo.download)
    logo_media_type = @team.logo.content_type

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
                media_type: logo_media_type,
                data: logo_base64
              }
            },
            {
              type: "text",
              text: "Describe this sports team logo's colours, style, and design elements in 2-3 sentences. Focus on colours, shapes, and visual style. Be specific and concise."
            }
          ]
        }
      ]
    )

    response.content.first.text
  end

  def build_prompt(logo_description)
    base = "Create a photo-realistic sports team jersey for a team called #{@team.name}. " \
           "The logo has the following design: #{logo_description}. " \
           "Use these colours and style for the jersey and incorporate the logo onto the chest. " \
           "The jersey should be modern, bold, and suitable for a professional sports team. " \
           "Show the jersey as a flat-lay on a clean neutral background and NOT worn by anyone. " \
           "Square 1:1 aspect ratio."

    base += " #{@description}." if @description.present?
    base
  end
end
