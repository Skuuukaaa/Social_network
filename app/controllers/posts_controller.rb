class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only: :destroy

  def index
    if params[:search].present?
      Post.reindex
      @posts = Post.search(params[:search], load: true)
    else
      @profile = Profile.find(params[:id])
      @user = @profile.user
      @posts = @user.posts
    end
  end

  def new
    @profile = Profile.find(params[:profile_id])
    @post = current_user.posts.build(profile_id: params[:profile_id])
  end

  def create
    @profile = current_user.profile
    @post = current_user.posts.create(post_params)
    if @post.save
      flash[:notice] = t('controllers.create')
    else
      flash[:alert] = 'Please fill all fields correctly'
    end
    redirect_to profile_path(@post.profile.id)
  end

  def update
    @profile = current_user.profile
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = t('controllers.update')
      redirect_to profile_path(@post.profile.id)
    else
      flash[:alert] = 'Please fill all fields correctly'
      render 'edit'
    end
  end

  def edit
    @profile = Profile.find(params[:profile_id])
    @post = current_user.posts.find(params[:id])
  end

  def show
    @post = current_user.posts.find(params[:id])
    @comment = @post.comments.find(params[:id])
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    if @post.destroy
      flash[:notice] = t('controllers.destroy')
      redirect_to profile_path(@post.profile.id)
    end
  end

  private

  def post_params
    params.require(:post).permit(:content, :picture, :heading, :user_id, :profile_id)
  end

  def correct_user
    @post = current_user.posts.find_by(id: params[:id])
    redirect_to root_url if @post.nil?
  end
end
