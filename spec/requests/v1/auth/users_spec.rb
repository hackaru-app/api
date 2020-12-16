# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Auth::Users', type: :request do
  describe 'POST /v1/auth/users' do
    let(:email) { 'foo@example.com' }

    before do
      perform_enqueued_jobs do
        post '/v1/auth/users',
             params: {
               user: {
                 email: email,
                 password: 'password',
                 time_zone: 'UTC',
                 locale: 'en'
               }
             }
      end
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'sends mail once' do
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'sends mail' do
      expect(ActionMailer::Base.deliveries.last.to.first).to eq(email)
    end

    it 'creates an user' do
      expect(User.find_by(email: 'foo@example.com')).not_to be_nil
    end

    it 'adds some sample projects' do
      user = User.find_by(email: 'foo@example.com')
      expect(user.projects.size).to eq(3)
    end
  end

  describe 'PUT /v1/auth/user' do
    let(:user) { create(:user, password: 'password') }
    let(:headers) { access_token_header(user) }

    before do
      put '/v1/auth/user',
          headers: headers,
          params: {
            user: {
              email: email,
              password: password,
              current_password: current_password
            }
          }
    end

    context 'when params have email and password' do
      let(:email) { 'changed@example.com' }
      let(:password) { 'changed' }
      let(:current_password) { 'password' }

      it { expect(response).to have_http_status(:ok) }
      it { expect(user.reload.email).to eq('changed@example.com') }
      it { expect(user.reload.authenticate('changed')).to be_truthy }
    end

    context 'when params have email only' do
      let(:email) { 'changed@example.com' }
      let(:password) { '' }
      let(:current_password) { 'password' }

      it { expect(response).to have_http_status(:ok) }
      it { expect(user.reload.email).to eq('changed@example.com') }
    end

    context 'when access tokens is invalid' do
      let(:email) { 'changed@example.com' }
      let(:password) { 'changed' }
      let(:current_password) { 'password' }
      let(:headers) { { 'X-Access-Token': 'invalid' } }

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(user.reload.email).not_to eq('changed@example.com') }
    end

    context 'when current password is invalid' do
      let(:email) { 'changed@example.com' }
      let(:password) { 'changed' }
      let(:current_password) { 'invalid' }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(user.reload.email).not_to eq('changed@example.com') }
    end
  end

  describe 'DELETE /v1/auth/user' do
    let(:user) { create(:user, password: 'password') }
    let(:headers) { access_token_header(user) }

    before do
      delete '/v1/auth/user',
             headers: headers,
             params: {
               user: {
                 current_password: current_password
               }
             }
    end

    context 'when current_password is valid' do
      let(:current_password) { 'password' }

      it { expect(response).to have_http_status(:ok) }
      it { expect(User).not_to exist(id: user.id) }
    end

    context 'when access tokens is invalid' do
      let(:current_password) { 'password' }
      let(:headers) { { 'X-Access-Token': 'invalid' } }

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(User).to exist(id: user.id) }
    end

    context 'when current_password is invalid' do
      let(:current_password) { 'invalid' }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(User).to exist(id: user.id) }
    end
  end
end
