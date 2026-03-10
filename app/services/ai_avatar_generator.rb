require "faraday"
require "faraday/multipart"
require "json"
require "base64"
require "stringio"

class AiAvatarGenerator
  MAX_AVATARS = 8  # limit to last 8 avatars

  def initialize(user)
    @user = user
  end

  def generate!
    raise "User has no avatar uploaded" unless @user.avatar.attached?

    # fetch API key as string, fail early if missing
    api_key = ENV.fetch("OPENAI_API_KEY") { raise "OPENAI_API_KEY not set" }.to_s

    conn = Faraday.new(url: "https://api.openai.com") do |f|
      f.request :multipart
      f.headers["Authorization"] = "Bearer #{api_key}"
    end

    response = conn.post("/v1/images/edits") do |req|
      req.body = {
        model: "gpt-image-1",
        prompt: "Generate a sports-style avatar of this person wearing a jersey keeping the style as photo realistic as possible and facing the camera.",
        image: Faraday::UploadIO.new(
          StringIO.new(@user.avatar.download),
          @user.avatar.content_type,
          "avatar.png"
        )
      }
    end

    json = JSON.parse(response.body)
    base64_image = json.dig("data", 0, "b64_json")
    raise "No image returned from OpenAI: #{json}" if base64_image.nil?

    decoded_image = Base64.decode64(base64_image)
    @user.ai_avatars.attach(
      io: StringIO.new(decoded_image),
      filename: "ai_avatar_#{Time.now.to_i}.png", # unique filename
      content_type: "image/png"
    )

    # keep only last 5 avatars
    if @user.ai_avatars.count > MAX_AVATARS
      @user.ai_avatars.order(created_at: :asc).first.purge
    end

    @user.save!

    @user.ai_avatars.last
  end
end
