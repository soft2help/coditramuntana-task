ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
  req = payload[:request]
  if [:blacklist, :throttle].include?(req.env["rack.attack.match_type"])
    if req.env["rack.attack.match_type"] == :throttle &&
        req.env["rack.attack.match_data"][:count] > Setting.get("api", "threshold_block_on_firewall").to_i

      # CloudflareApi.new.block_ip(req.env["rack.attack.match_data"][:discriminator])

    end

    Rails.logger.warn "[Rack::Attack][Blocked] Remote IP: #{req.ip}, Path: #{req.path}, Matched: #{req.env["rack.attack.matched"]}, Match Type: #{req.env["rack.attack.match_type"]}"
  end
end

class Rack::Attack
  blocklist("block all access") do |req|
    blocked_list_ip = begin
      JSON.parse(Setting.get("api", "throttling_ip_block_list"))
    rescue
      []
    end

    # Requests are blocked if the return value is truthy
    blocked_list_ip.include?(req.ip)
  end

  safelist("allow list") do |req|
    allow_list_ip = begin
      JSON.parse(Setting.get("api", "throttling_ip_allow_list"))
    rescue
      []
    end
    # Requests are allowed if the return value is truthy
    allow_list_ip.include?(req.ip)
  end

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  # the key returned in block will be the descriminator
  # we can change limit and period based on the request user/roles or any other parameter

  period_proc = proc do |req|
    @roles = req.env["authenticated_by_middleware"]&.bearer&.roles || []
    if @roles.include? [:super_admin]
      10.minutes
    else
      1.minutes
    end
  rescue
    1.minutes
  end

  limit_proc = proc do |req|
    # if we use memoization because alreay was asigned in period_proc
    @roles ||= req.env["authenticated_by_middleware"]&.bearer&.roles || []
    if @roles.include? [:super_admin]
      100
    else
      20
    end
  rescue
    20
  end

  throttle("req/ip", limit: limit_proc, period: period_proc) do |req|
    req.ip unless req.path.start_with?("/api-docs/")
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_responder = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end

  self.throttled_responder = lambda do |rack_req|
    match_data = rack_req.env["rack.attack.match_data"]
    now = match_data[:epoch_time]

    headers = {
      "RateLimit-Limit" => match_data[:limit].to_s,
      "RateLimit-Remaining" => "0",
      "RateLimit-Reset" => (now + (match_data[:period] - now % match_data[:period])).to_s
    }

    errors_api = Api::Errors.new([Api::Error.new("TOO-MANY-REQUESTS", "Too many requests")])
    # TODO: implement this
    # change http code if number of requests is higher than a given limit (threshold defined by us)

    [429, headers, [errors_api.as_json.to_json]]
  end
end
