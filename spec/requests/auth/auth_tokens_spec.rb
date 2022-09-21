# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth::AuthTokens', type: :request do
  describe 'POST /auth/auth_tokens' do
    let(:headers) { xhr_header }
    let(:user) { create(:user) }
    let(:email) { user.email }
    let(:password) { user.password }

    it_behaves_like 'validates xhr' do
      before do
        post '/auth/auth_tokens',
             headers: headers,
             params: {
               user: {
                 email: user.email,
                 password: user.password
               }
             }
      end
    end

    context 'when email and password are valid' do
      before do
        post '/auth/auth_tokens',
             headers: headers,
             params: {
               user: {
                 email: user.email,
                 password: user.password
               }
             }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response.cookies).to include('auth_token_id') }
      it { expect(response.cookies).to include('auth_token_raw') }
    end

    context 'when email is invalid' do
      before do
        post '/auth/auth_tokens',
             headers: headers,
             params: {
               user: {
                 email: 'test@example.com',
                 password: user.password
               }
             }
      end

      it { expect(response).to have_http_status(:bad_request) }
    end

    context 'when password is invalid' do
      before do
        post '/auth/auth_tokens',
             headers: headers,
             params: {
               user: {
                 email: user.email,
                 password: 'invalid'
               }
             }
      end

      it { expect(response).to have_http_status(:bad_request) }
    end

    context 'when password is missing' do
      before do
        post '/auth/auth_tokens',
             headers: headers,
             params: {
               user: {
                 email: user.email
               }
             }
      end

      it { expect(response).to have_http_status(:bad_request) }
    end

    context 'when all params are missing' do
      before do
        post '/auth/auth_tokens',
             headers: headers,
             params: {
             }
      end

      it { expect(response).to have_http_status(:bad_request) }
    end
  end

  describe 'DELETE /auth/auth_tokens' do
    let(:headers) { xhr_header }
    let(:current_user) { create(:user) }

    before do
      login(current_user)
      delete '/auth/auth_token',
             headers: headers
    end

    around do |e|
      travel_to('2021-01-01 00:00:00') { e.run }
    end

    it_behaves_like 'validates xhr'

    context 'when user logged in' do
      it { expect(response).to have_http_status(:no_content) }
      it { expect(current_user.auth_tokens.first.expired_at).to eq(Time.zone.now) }
    end

    context 'when user is not logged in' do
      let(:current_user) { nil }

      it { expect(response).to have_http_status(:no_content) }
    end
  end
end
