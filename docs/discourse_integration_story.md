# Discourse Integration Story

This Rails app demonstrates the integration pattern for a Community application that owns identity and connects users to Discourse.

## 1. Okta/OIDC authenticates the user

Okta is the identity provider. The Community app receives OIDC claims and creates or updates the local user in `app/services/users/find_or_provision_from_okta.rb`.

If the enterprise uses SAML instead of OIDC, the story is the same after login: SAML authenticates the user into Community, then Community becomes the trusted source for Discourse.

```ruby
User.find_or_initialize_by(okta_uid: uid).tap do |user|
  user.email = email
  user.name = name
  user.discourse_username ||= default_discourse_username
  user.active = true
  user.save!
end
```

## 2. Discourse redirects to Community for SSO

The SSO endpoint is declared in `config/routes.rb`:

```ruby
namespace :discourse do
  get "sso", to: "sso#show"
end
```

The controller is `app/controllers/discourse/sso_controller.rb`. It requires a logged-in Community user, then redirects to the signed Discourse login URL.

## 3. Community signs the DiscourseConnect payload

`app/services/discourse/sso_redirect_url.rb` parses Discourse's request, preserves the nonce, and signs the response with the shared secret.

```ruby
incoming = DiscourseApi::SingleSignOn.parse(request_query, sso_secret)
response = DiscourseApi::SingleSignOn.new

response.nonce = incoming.nonce
response.external_id = user.id.to_s
response.email = user.email
response.username = user.discourse_username
response.admin = user.discourse_admin?
response.moderator = user.discourse_moderator?
response.groups = user.discourse_group_names
```

The important security detail is the nonce. It connects Discourse's original login request to Community's signed response.

## 4. The Discourse API handles lifecycle sync

SSO is for login. Ongoing lifecycle changes use the Discourse API through `app/clients/discourse/client.rb`.

The app syncs:

- user profile data in `app/services/discourse/sync_user.rb`
- group and staff roles in `app/services/discourse/sync_user_groups.rb`
- deactivation in `app/services/discourse/deactivate_user.rb`

## 5. Webhooks bring Discourse events back

Discourse sends signed events to `app/controllers/discourse/webhooks_controller.rb`.

The app verifies signatures in `app/services/discourse/verify_webhook_signature.rb`, stores events idempotently in `DiscourseWebhookEvent`, and queues delivery through `app/jobs/discourse/deliver_webhook_to_snowflake_job.rb`.

## 6. Tests prove the contract

Run:

```bash
bundle exec rspec
```

The suite covers SSO signing, API adapter behavior, user sync, group sync, deactivation, webhook verification, webhook idempotency, and Snowflake delivery boundaries.

