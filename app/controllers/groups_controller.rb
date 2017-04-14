class GroupsController < ApplicationController
   before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy, :join, :quit]
  def index
    @groups =  Group.all
  
  end

  def new
    @group = Group.new
  end

  def show
    @group = Group.find(params[:id])
     @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
end

def edit
  @group = Group.find(params[:id])

  if current_user != @group.user
    redirect_to root_path, alert: "You have no permission."
  end
end

  def create
    @group = Group.new(group_params)
    @group.user = current_user

    if @group.save
      current_user.join!(@group)
      redirect_to groups_path
    else
      render :new
    end
  end

  def update
     @group = Group.find(params[:id])

     if current_user != @group.user
       redirect_to root_path, alert: "You have no permission."
     end

     if @group.update(group_params)
       redirect_to groups_path, notice: "Update Success"
     else
       render :edit
     end
   end

   def destroy
     @group = Group.find(params[:id])

     if current_user != @group.user
       redirect_to root_path, alert: "You have no permission."
     end

     @group.destroy
     redirect_to groups_path, alert: "Group deleted"
   end

   def join
     @group = Group.find(params[:id])
     if !current_user.is_member_of?(@group)
       current_user.join!(@group)
       flash[:notice] = "成功加入讨论版"
     else
       flash[:warning] = "你已经是本群成员了"
     end
     redirect_to group_path(@group)
   end

def quit
  @group = Group.find(params[:id])
   if current_user.is_member_of?(@group)
     current_user.quit!(@group)
     flash[:alert] = "已退出本讨论群！"
   else

    flash[:warning] = "你不是本群成员，怎么退出"
  end

   redirect_to group_path(@group)
 end

   end




  private

  def group_params
    params.require(:group).permit(:title, :description)
  end
