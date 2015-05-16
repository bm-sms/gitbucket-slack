class Hook < ActiveRecord::Base
  self.primary_key = :id

  validates_presence_of :slack_hook

  def self.new_endpoint
    new(id: Digest::MD5.new.update(Random.new_seed.to_s))
  end

  def notify(payload)
    uri = URI.parse(slack_hook)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    req = Net::HTTP::Post.new(uri.request_uri)

    if pull_request = payload['pull_request']
      notify_pull_request(pull_request, http, req)
    elsif commits = payload['commits']
      notify_commits(commits, http, req)
    end
  end

  private

  def notify_pull_request(pull_request, http, req)
    message = "#{pull_request['user']['login']} opened pull request #{pull_request['html_url']}\r\n*#{pull_request['title']}*\r\n#{pull_request['body']}"

    req.set_form_data(payload: {text: message}.to_json)
    http.request(req)
  end

  def notify_commits(commits, http, req)
    commits.each do |commit|
      message = "#{commit['message']} commited by #{commit['committer']['name']}"
      req.set_form_data(payload: {text: message}.to_json)
      http.request(req)
    end
  end
end
