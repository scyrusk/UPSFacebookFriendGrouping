class PostsController < ApplicationController
  def index
    @user = User.find_by_link(params[:id])
    @type = params[:type]
    if @user != nil && @type != nil
      @create = params[:uc]
      if @create.casecmp("u") == 0
        @post = Post.find(params[:postid])
      else
        @post = Post.new do |p|
          dateSplit = params[:date].split("/")
          p.sms_date = DateTime.new(dateSplit[0].to_i,dateSplit[1].to_i,dateSplit[2].to_i).to_s
          p.post_date = p.sms_date
          p.sms_body = "[Blank]"
          p.kind = @type
          p.user = @user
          p.completed = false
          p.save
        end
      end
      @link = 'home?id=' << params[:id] << ";date=" << @post.sms_date.strftime('%Y/%m/%d') << ";postid=" << @post.id.to_s << ";uc=" << params[:uc]
    end
  end
end
