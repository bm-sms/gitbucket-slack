class Hook < ActiveRecord::Base
  self.primary_key = :id

  validates_presence_of :slack_hook

  def self.new_endpoint(params = {})
    new(params.merge(id: Digest::MD5.new.update(Random.new_seed.to_s)))
  end

  def notify(payload)
    if pull_request = payload['pull_request']
      notify_pull_request(pull_request)
    elsif commits = payload['commits']
      notify_commits(commits)
    end
  end

  private

  def notify_pull_request(pull_request)
    post do |requester|
      message = <<-EOM.strip_heredoc
        #{pull_request['user']['login']} opened pull request #{pull_request['html_url']}

        *#{pull_request['title']}*
        #{pull_request['body']}
      EOM

      requester.call(message)
    end
  end

  def notify_commits(commits)
    post do |requester|
      commits.each do |commit|
        message = "#{commit['message']} commited by #{commit['committer']['name']}"

        requester.call(message)
      end
    end
  end

  def post
    uri = URI.parse(slack_hook)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    req = Net::HTTP::Post.new(uri.request_uri)

    yield ->(message) {
        req.set_form_data(payload: {text: message}.to_json)
        http.request(req)
      }
  end
end
