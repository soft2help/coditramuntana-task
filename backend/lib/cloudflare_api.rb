class CloudflareApi
  include HTTParty
  base_uri "https://api.cloudflare.com/client/v4"

  def initialize
    @options = {
      headers: {
        "Authorization" => "Bearer #{Rails.application.credentials.cloudflare[:api_key]}",
        "Content-Type" => "application/json"
      },
      body: {}.to_json
    }
    @account_id = account_id
  end

  def block_ip(ip_to_block)
    body = {
      mode: "block",
      configuration: {
        target: "ip",
        value: ip_to_block
      },
      notes: "Blocked via API for specific reason"
    }

    self.class.post("/zones/#{Rails.application.credentials.cloudflare[:zone_id]}/firewall/access_rules/rules", @options.merge(body: body.to_json))
  end

  def list
    self.class.get("/zones/#{Rails.application.credentials.cloudflare[:zone_id]}/firewall/access_rules/rules")
  end

  def delete(rule_id)
    self.class.delete("/zones/#{Rails.application.credentials.cloudflare[:zone_id]}/firewall/access_rules/rules/#{rule_id}")
  end
end
