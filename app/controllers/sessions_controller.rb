# coding: utf-8
class SessionsController < ApplicationController
  def create
    user = User.authenticate(params[:username], params[:password])
    if user
      session[:username] = user.username
      redirect_to :back
    else
      redirect_to root_url, notice: 'ログインに失敗しました。'
    end
  end

  def destroy
    session[:username] = nil
    redirect_to root_url
  end

  def twitter_create
    auth = request.env['omniauth.auth']
    screen_name = auth[:info][:nickname]
    profile_image = auth[:info][:image]
    uid = auth[:uid]

    raise Forbidden unless auth
    if session[:username] == nil
      user = TwitterAccount.find_by_uid(uid).user

      if user
        session[:username] = user.username
        redirect_to root_url
      else
        redirect_to '/registration', notice: 'ご使用のアカウント(' +
        screen_name + ')はBEATECHアカウントに関連付けられていないようです。' +
        'お手数ですが、まずBEATECHアカンウントを作成してください。'
      end
    else
      user = User.find_by_username(session[:username])
      user.profile_image = profile_image
      user.save
      if TwitterAccount.exist?(screen_name) == true
        redirect_to(
          root_url + 'users/edit/' + session[:account],
          notice: "#{screen_name}はすでにBEATECHアカウントに関連付けられています。"
        )
      else
        TwitterAccount.create(
          user_id: User.find_by_account(session[:account]).id,
          uid: uid,
          screen_name: screen_name
        )
        begin
          # command = 'ruby script/follow.rb ' + uid.to_s
          # system(command)
        ensure
          redirect_to(
            root_url + 'users/edit/' + session[:account],
            notice: 'アカウントを追加しました。'
          )
        end
      end
    end
  end
end
