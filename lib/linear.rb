class Linear
  BASE_URL = 'https://api.linear.app/graphql'.freeze
  REVOKE_URL = 'https://api.linear.app/oauth/revoke'.freeze
  PRIORITY_LEVELS = (0..4).to_a

  def initialize(access_token)
    @access_token = access_token
    raise ArgumentError, 'Missing Credentials' if access_token.blank?
  end

  def teams
    query = {
      query: Linear::Queries::TEAMS_QUERY
    }
    response = post(query)
    process_response(response)
  end

  def team_entities(team_id)
    raise ArgumentError, 'Missing team id' if team_id.blank?

    query = {
      query: Linear::Queries.team_entities_query(team_id)
    }
    response = post(query)
    process_response(response)
  end

  def search_issue(term)
    raise ArgumentError, 'Missing search term' if term.blank?

    query = {
      query: Linear::Queries.search_issue(term)
    }
    response = post(query)
    process_response(response)
  end

  def linked_issues(url)
    raise ArgumentError, 'Missing link' if url.blank?

    query = {
      query: Linear::Queries.linked_issues(url)
    }
    response = post(query)
    process_response(response)
  end

  def create_issue(params, user = nil)
    validate_team_and_title(params)
    validate_priority(params[:priority])
    validate_label_ids(params[:label_ids])

    variables = build_issue_variables(params, user)
    mutation = Linear::Mutations.issue_create(variables)
    response = post({ query: mutation })
    process_response(response)
  end

  def link_issue(link, issue_id, title, user = nil)
    raise ArgumentError, 'Missing link' if link.blank?
    raise ArgumentError, 'Missing issue id' if issue_id.blank?

    link_params = build_link_params(issue_id, link, title, user)
    payload = { query: Linear::Mutations.issue_link(link_params) }

    response = post(payload)
    process_response(response)
  end

  def unlink_issue(link_id)
    raise ArgumentError, 'Missing  link id' if link_id.blank?

    payload = {
      query: Linear::Mutations.unlink_issue(link_id)
    }
    response = post(payload)
    process_response(response)
  end

  def revoke_token
    response = HTTParty.post(
      REVOKE_URL,
      headers: { 'Authorization' => "Bearer #{@access_token}", 'Content-Type' => 'application/json' }
    )
    response.success?
  end

  private

  def build_issue_variables(params, user)
    variables = {
      title: params[:title],
      teamId: params[:team_id],
      description: params[:description],
      assigneeId: params[:assignee_id],
      priority: params[:priority],
      labelIds: params[:label_ids],
      projectId: params[:project_id],
      stateId: params[:state_id]
    }.compact

    # Add user attribution if available
    if user&.name.present?
      variables[:createAsUser] = user.name
      variables[:displayIconUrl] = user.avatar_url if user.avatar_url.present?
    end

    variables
  end

  def build_link_params(issue_id, link, title, user)
    params = {
      issue_id: issue_id,
      link: link,
      title: title
    }

    if user.present?
      params[:user_name] = user.name if user.name.present?
      params[:user_avatar_url] = user.avatar_url if user.avatar_url.present?
    end

    params
  end

  def validate_team_and_title(params)
    raise ArgumentError, 'Missing team id' if params[:team_id].blank?
    raise ArgumentError, 'Missing title' if params[:title].blank?
  end

  def validate_priority(priority)
    return if priority.nil? || PRIORITY_LEVELS.include?(priority)

    raise ArgumentError, 'Invalid priority value. Priority must be 0, 1, 2, 3, or 4.'
  end

  def validate_label_ids(label_ids)
    return if label_ids.nil?
    return if label_ids.is_a?(Array) && label_ids.all?(String)

    raise ArgumentError, 'label_ids must be an array of strings.'
  end

  def post(payload)
    HTTParty.post(
      BASE_URL,
      headers: { 'Authorization' => "Bearer #{@access_token}", 'Content-Type' => 'application/json' },
      body: payload.to_json
    )
  end

  def process_response(response)
    return response.parsed_response['data'].with_indifferent_access if response.success? && !response.parsed_response['data'].nil?

    { error: response.parsed_response, error_code: response.code }
  end
end
